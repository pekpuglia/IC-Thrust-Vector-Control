include("../src/nozzle_design.jl")
##
required_thrust = 5.0 #N
chamber_pressure = 500.0    #kPa
prop_temperature = 298.15
min_diam = 8.4   #mm
##
opcond = CEAInterface.OperatingCondition(chamber_pressure,
                100.0, "N2", prop_temperature)
areas = NozzleProject.NozzleAreas(required_thrust, opcond, min_chamber_radius_mm=min_diam/2)
nozzle_geom = NozzleProject.NozzleGeometry(areas, 15.0,
                        45.0, 20.0, 3.0)
##
#verify speed in tube
mdot = NozzleProject.get_mdot(required_thrust, opcond)
MM = 28.0
d = 1/8 * 0.0254
v = mdot * 8.314 * prop_temperature/ (π * (d/2) ^ 2 * chamber_pressure * MM)
##
using GLMakie
##
contour = NozzleDraw.generate_nozzle_contour(nozzle_geom)
base = NozzleDraw.generate_solid(contour)
connected = NozzleDraw.add_connector_hole(base, nozzle_geom, min_diam)
stagnator = NozzleDraw.add_stagnator(connected, nozzle_geom, 0.2, 0.5)
##
NozzleDraw.export_stl("base.stl", base)
NozzleDraw.export_stl("connected.stl", connected, rtol=1e-3, atol=1e-3)
