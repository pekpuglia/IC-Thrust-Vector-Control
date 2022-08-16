module RocketCeaTest
using Test
include("../src/nozzle_design.jl")
#https://rocketcea.readthedocs.io/en/latest/quickstart.html
function test_rocket_cea()
    C = CEAInterface.CEA_OBJ.CEA_Obj(oxName="LOX", fuelName="LH2")
    return C.get_Isp() ≈ 374.30361765576265
end

function test_get_ambient_Isp()
    #monoprop padrao
    propellant = CEAInterface.Propellant("N2", 28u"g/mol", 298.15u"K") 
	nozzle_cond = CEAInterface.OperatingCondition(500.0u"kPa", 100.0u"kPa", propellant)
    return CEAInterface.get_ambient_Isp(nozzle_cond, 1.5) isa Tuple
end

function test_get_ambient_cf()
    propellant = CEAInterface.Propellant("N2", 28u"g/mol", 298.15u"K") 
	nozzle_cond = CEAInterface.OperatingCondition(500.0u"kPa", 100.0u"kPa", propellant)
    return CEAInterface.get_ambient_Cf(nozzle_cond, 1.5) isa Tuple
end

function test_get_Cstar()
    propellant = CEAInterface.Propellant("N2", 28u"g/mol", 298.15u"K") 
	nozzle_cond = CEAInterface.OperatingCondition(500.0u"kPa", 100.0u"kPa", propellant)
    return CEAInterface.get_Cstar(nozzle_cond) isa Float64
end

function test_get_densities()
    propellant = CEAInterface.Propellant("N2", 28u"g/mol", 298.15u"K") 
	nozzle_cond = CEAInterface.OperatingCondition(500.0u"kPa", 100.0u"kPa", propellant)
    dens = CEAInterface.get_densities(nozzle_cond, 1.5)
    return all(dens[2:end] .< dens[1:(end-1)])    
end

function test_get_exit_mach()
    propellant = CEAInterface.Propellant("N2", 28u"g/mol", 298.15u"K") 
	nozzle_cond = CEAInterface.OperatingCondition(500.0u"kPa", 100.0u"kPa", propellant)
    return CEAInterface.get_exit_mach(nozzle_cond, 1.5) isa Float64
end

function test_get_sonic_speeds()
    propellant = CEAInterface.Propellant("N2", 28u"g/mol", 298.15u"K") 
	nozzle_cond = CEAInterface.OperatingCondition(500.0u"kPa", 100.0u"kPa", propellant)
    speeds = CEAInterface.get_sonic_speeds(nozzle_cond, 1.5)
    return all(speeds[2:end] .< speeds[1:(end-1)])
end

function test_get_temperatures()
    propellant = CEAInterface.Propellant("N2", 28u"g/mol", 298.15u"K") 
	nozzle_cond = CEAInterface.OperatingCondition(500.0u"kPa", 100.0u"kPa", propellant)
    temps = CEAInterface.get_temperatures(
    nozzle_cond, 1.5)
    return all(temps[2:end] .< temps[1:(end-1)])
end

function test_get_exp_ratio()
    propellant = CEAInterface.Propellant("N2", 28u"g/mol", 298.15u"K") 
	nozzle_cond = CEAInterface.OperatingCondition(500.0u"kPa", 100.0u"kPa", propellant)
    return CEAInterface.get_exp_ratio(nozzle_cond) > 1
end

function test_add_new_propellant()
    ret = false
    try
        propellant = CEAInterface.Propellant("N2", 28u"g/mol", 298.15u"K") 
	    nozzle_cond = CEAInterface.OperatingCondition(500.0u"kPa", 100.0u"kPa", propellant)
        CEAInterface.get_ambient_Isp(nozzle_cond, 1.5)
        ret = true
    catch
    end
    return ret
end

function test_nozzle_conditions()
    propellant = CEAInterface.Propellant("N2", 28u"g/mol", 298.15u"K") 
	nozzle_cond = CEAInterface.OperatingCondition(500.0u"kPa", 100.0u"kPa", propellant)
    return CEAInterface.get_ambient_Isp(nozzle_cond, 1.5) isa Tuple
end
#adicionar testes do OperatingCondition
@testset "Test rocket cea" begin
    @test test_rocket_cea()
    @test test_get_ambient_Isp()
    @test test_get_ambient_cf()
    @test test_get_Cstar()
    @test test_get_densities()
    @test test_get_exit_mach()
    @test test_get_sonic_speeds()
    @test test_get_temperatures()
    @test test_get_exp_ratio()
    @test test_add_new_propellant()
    @test test_nozzle_conditions()
end
end