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
using .NozzleDraw
nozzle_geom = RoundNozzle(areas, 5.0u"°",
                        45.0u"°", 30.0u"mm", 3.0u"mm")
connector_hole = ConnectorHole(
    min_diam, 
    nozzle_geom.thickness,
    [0.0,0,0], 
    [0.0,0,-1]
)
hex_base = HexBase(10.0u"mm", nozzle_geom.thickness)

probe_hole = ProbeHole(
    NozzleDraw.side_length(hex_base, nozzle_geom),
    2.5 * min_diam,
    nozzle_geom.thickness,
    min_diam,
    hex_base.height - nozzle_geom.thickness
)

feats = [connector_hole, hex_base, probe_hole]
##
probed = build_nozzle(nozzle_geom, feats)