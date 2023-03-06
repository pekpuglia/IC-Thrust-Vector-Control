using Revise
using GLMakie
using ConstructiveGeometry
##
include("../src/nozzle_design.jl")
using .NozzleDraw
##
required_thrust = 5.0u"N" #N
#deveria ser 600?
chamber_pressure = 500.0u"kPa"  #kPa
prop_temperature = 298.15u"K"
conn_diam = 11u"mm"   #mm
##
propellant = CEAInterface.Propellant("Air", 28.9u"g/mol", prop_temperature)

opcond = CEAInterface.OperatingCondition(chamber_pressure,
                100.0u"kPa", propellant)

areas = NozzleProject.NozzleAreas(required_thrust, opcond, 
                contraction_ratio=50.0)
##
#verify speed in tube
mdot = NozzleProject.get_mdot(required_thrust, opcond)
NozzleProject.pipe_speed(mdot, opcond, 1/4 * u"inch")
##

function reduce_areas(areas::NozzleProject.NozzleAreas, diameter_reduction::Unitful.Length)
    radii = NozzleDraw.get_radii(areas)
    NozzleProject.NozzleAreas(
        areas.Achamber,
        (radii[2] - diameter_reduction/2)^2 * π,
        (radii[3] - diameter_reduction/2)^2 * π,
    )
end

function add_features(nozzle_geom)
    base_pads = [
        Pad(
            2*conn_diam,
            10u"mm"+2*conn_diam,
            nozzle_geom.thickness,
            -nozzle_geom.thickness,
            angle*u"°"
        )
        for angle in 0:90:270
    ]
    
    gas_hole = SideHole(
        2*conn_diam,
        2*conn_diam,
        nozzle_geom.thickness,
        10u"mm" - nozzle_geom.thickness,
        90u"°",
        conn_diam
    )
    build_nozzle(nozzle_geom, base_pads..., gas_hole)
end

function nozzle_with_corrected_diameter(areas::NozzleProject.NozzleAreas, diameter_reduction::Unitful.Length)
    true_areas = reduce_areas(areas, diameter_reduction)
    nozzle_geom = RoundNozzle(true_areas, 5.0u"°", 45.0u"°", 30.0u"mm", 3.0u"mm")
    add_features(nozzle_geom)
end

##
for diam_reduction in (0:0.1:0.4)u"mm"
    corrected_nozzle = nozzle_with_corrected_diameter(areas, diam_reduction)
    NozzleDraw.export_stl("./nozzle_design/geometry/iter4_fix_thrust/corrected_nozzle_$(diam_reduction).stl", corrected_nozzle, rtol=1e-2, atol=1e-2)
end
##
#encaixe na bancada de empuxo
filled_motor = union(air_motor, 
    [0,0,-mm(nozzle_geom.thickness)] 
    + linear_extrude(10) 
    * circle(
        mm(
            NozzleDraw.get_radius(nozzle_geom.areas.Achamber)
            + nozzle_geom.thickness
        ) + 1e-2
    )
)
t = mm(nozzle_geom.thickness)
nozzle_OD = mm(2*NozzleDraw.get_radius(nozzle_geom.areas.Achamber)) + 2t

screw_support = [-30-nozzle_OD/2-2t, 0, 0] + 
        linear_extrude(12) * (square(60, nozzle_OD+2t, center=true)
        \ ([-22, 0] + union(circle(2.5), [11, 0] + circle(2.5)))
    )


nozzle_support = union(
    #bloco quadrado
    linear_extrude(20) * square(nozzle_OD + 4t, center=true),
    #suporte dos p=arafusos [nozzle_OD/2+2t, 0, 0] + 
    screw_support
)

#recesso do motor
nozzle_support =  nozzle_support \ ([0, 0, 10 + NozzleDraw.mm(nozzle_geom.thickness)] + filled_motor)

##
NozzleDraw.export_stl("./nozzle_design/geometry/iter3/support.stl", nozzle_support, rtol=1e-2, atol=1e-2)