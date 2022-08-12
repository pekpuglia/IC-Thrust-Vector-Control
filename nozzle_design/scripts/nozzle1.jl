include("../src/nozzle_design.jl")
##
required_thrust = 5.0 #N
chamber_pressure = 500.0    #kPa
ambient_pressure = 100.0    #kPa
prop_temperature = 298.15
##
opcond = CEAInterface.OperatingCondition(chamber_pressure,
                ambient_pressure, "N2", prop_temperature)
areas = NozzleProject.NozzleAreas(required_thrust, opcond)
nozzle_geom = NozzleProject.NozzleGeometry(areas, 15.0,
                        45.0, 20.0, 3.0)
##
#verify speed in tube
mdot = NozzleProject.get_mdot(5.0, opcond)
MM = 28.0
d = 1/8 * 0.0254
v = mdot * 8.314 * prop_temperature/ (π * (d/2) ^ 2 * chamber_pressure * MM)