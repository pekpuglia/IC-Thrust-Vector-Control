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
                min_chamber_radius=conn_diam/2,
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

#sempre gera face virada p x
poly_base = PolyBase(10.0u"mm", nozzle_geom.thickness, 4)

#controlar azimute, renomear
probe_hole = SideHole(
    2*conn_diam,
    2 * conn_diam,
    nozzle_geom.thickness,
    poly_base.height - nozzle_geom.thickness,
    0u"°",
    conn_diam
)

gas_hole = SideHole(
    2*conn_diam,
    2*conn_diam,
    nozzle_geom.thickness,
    poly_base.height - nozzle_geom.thickness,
    90u"°",
    conn_diam
)
##
octa = build_nozzle(nozzle_geom, poly_base, probe_hole, gas_hole)
##
NozzleDraw.export_stl("./nozzle_design/geometry/iter3/octagon.stl", octa)
##
#encaixe na bancada de empuxo
support = linear_extrude(30) *
        polygon(NozzleDraw.poly(41.7/2, 6)) \
        (
            [0,0,20] + linear_extrude(10) *
            polygon(NozzleDraw.poly(NozzleDraw.mm(
                poly_base.clearance
                +nozzle_geom.thickness
                +NozzleDraw.get_radius(nozzle_geom.areas.Achamber)
                ), poly_base.n)
            )
        )