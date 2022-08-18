include("../src/nozzle_design.jl")
##
required_thrust = 5.0u"N" #N
chamber_pressure = 500.0u"kPa"  #kPa
prop_temperature = 298.15u"K"
min_diam = 8.4u"mm"   #mm
##
propellant = CEAInterface.Propellant("N2", 28u"g/mol", prop_temperature)

opcond = CEAInterface.OperatingCondition(chamber_pressure,
                100.0u"kPa", propellant)

areas = NozzleProject.NozzleAreas(required_thrust, opcond, 
                min_chamber_radius=min_diam/2,
                contraction_ratio=50.0)
##
#verify speed in tube
mdot = NozzleProject.get_mdot(required_thrust, opcond)
NozzleProject.pipe_speed(mdot, opcond, 1/4 * u"inch")
##
using GLMakie
using ConstructiveGeometry
##
nozzle_geom = NozzleDraw.RoundNozzle(areas, 5.0u"°",
                        45.0u"°", 30.0u"mm", 3.0u"mm")
nozzle = NozzleDraw.build_nozzle(nozzle_geom)
connected = NozzleDraw.add_connector_hole(nozzle, nozzle_geom, min_diam)
hexagon = NozzleDraw.add_hexagonal_base(connected, nozzle_geom, 10.0)
##
NozzleDraw.export_stl("./nozzle_design/geometry/iter2/connected.stl",
         connected, rtol=1e-3, atol=1e-3)
NozzleDraw.export_stl("./nozzle_design/geometry/iter2/hexagon.stl", hexagon, rtol=1e-3, atol=1e-3)
#TODO: add probe opening