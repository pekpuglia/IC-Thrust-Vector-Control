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
                min_chamber_radius_mm=min_diam/2,
                contraction_ratio=20.0)
nozzle_geom = NozzleProject.NozzleGeometry(areas, 5.0,
                        45.0, 50.0, 3.0)
##
#verify speed in tube
mdot = NozzleProject.get_mdot(required_thrust, opcond)
MM = 28.0
d = 1/4 * 0.0254
v = mdot * 8.314 * prop_temperature/ (π * (d/2) ^ 2 * chamber_pressure * MM)
##
using GLMakie
##
contour = NozzleDraw.generate_nozzle_contour(nozzle_geom)
base = NozzleDraw.generate_solid(contour)
connected = NozzleDraw.add_connector_hole(base, nozzle_geom, min_diam)
##
NozzleDraw.export_stl("connected.stl", connected, rtol=1e-3, atol=1e-3)
