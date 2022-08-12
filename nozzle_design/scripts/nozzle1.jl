include("../src/nozzle_design.jl")
##
opcond = CEAInterface.OperatingCondition(500.0, 100.0, "N2", 298.15)
areas = NozzleProject.NozzleAreas(5.0, opcond)
nozzle_geom = NozzleProject.NozzleGeometry(areas, 15.0,
                        45.0, 20.0, 3.0)
