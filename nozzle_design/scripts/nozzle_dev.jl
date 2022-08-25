include("../src/nozzle_design.jl")
##
required_thrust = 5.0u"N" #N
chamber_pressure = 500.0u"kPa"  #kPa
prop_temperature = 298.15u"K"
conn_diam = 11u"mm"   #mm
##
propellant = CEAInterface.Propellant("N2", 28u"g/mol", prop_temperature)

opcond = CEAInterface.OperatingCondition(chamber_pressure,
                100.0u"kPa", propellant)

areas = NozzleProject.NozzleAreas(required_thrust, opcond, 
                contraction_ratio=50.0)
##
#verify speed in tube
mdot = NozzleProject.get_mdot(required_thrust, opcond)
NozzleProject.pipe_speed(mdot, opcond, 1/4 * u"inch")
##
using GLMakie
using ConstructiveGeometry
##
using .NozzleDraw
nozzle_geom = RoundNozzle(areas, 5.0u"°",
                        45.0u"°", 30.0u"mm", 3.0u"mm")

base_pads = [
    Pad(
        1.8*conn_diam,
        10u"mm",
        nozzle_geom.thickness,
        -nozzle_geom.thickness,
        angle*u"°"
    )
    for angle in 0:90:270
]
# poly_base = PolyBase(10.0u"mm", 1.5nozzle_geom.thickness, 8)

#controlar azimute, renomear
probe_hole = SideHole(
    1.8*conn_diam,
    2*conn_diam,
    nozzle_geom.thickness,
    10u"mm" - nozzle_geom.thickness,
    0u"°",
    conn_diam
)

gas_hole = SideHole(
    1.8*conn_diam,
    2*conn_diam,
    nozzle_geom.thickness,
    10u"mm" - nozzle_geom.thickness,
    90u"°",
    conn_diam
)
##
padded_side_holes = build_nozzle(nozzle_geom, base_pads..., probe_hole, gas_hole)
plot(padded_side_holes)
##
NozzleDraw.export_stl("./nozzle_design/geometry/iter3/padded_side_holes.stl", padded_side_holes)
##
#encaixe na bancada de empuxo
support = linear_extrude(30) *
        polygon(NozzleDraw.poly(41.7/2, 6)) \
        (
            [0,0,20+NozzleDraw.mm(nozzle_geom.thickness)] 
            + union(padded_side_holes, 
                [0,0,-NozzleDraw.mm(nozzle_geom.thickness)] +linear_extrude(10) 
                * circle(
                    NozzleDraw.mm(
                        NozzleDraw.get_radius(nozzle_geom.areas.Achamber)
                        + nozzle_geom.thickness
                    ) + 1e-2
                )
            )
        )
##
NozzleDraw.export_stl("./nozzle_design/geometry/iter3/support.stl", support)