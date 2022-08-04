module RocketCeaTest
using Test
include("../src/cea_interface.jl")
#https://rocketcea.readthedocs.io/en/latest/quickstart.html
function test_rocket_cea()
    C = CEAInterface.CEA_OBJ.CEA_Obj(oxName="LOX", fuelName="LH2")
    return C.get_Isp() ≈ 374.30361765576265
end

function test_get_ambient_Isp()
    #monoprop padrao
    nozzle_cond = CEAInterface.NozzleConditions(5.0, 1.0, "HYD40")
    return CEAInterface.get_ambient_Isp(nozzle_cond, 1.5) isa Tuple
end

function test_get_ambient_cf()
    nozzle_cond = CEAInterface.NozzleConditions(5.0, 1.0, "HYD40")
    return CEAInterface.get_ambient_Cf(nozzle_cond, 1.5) isa Tuple
end

function test_get_Cstar()
    nozzle_cond = CEAInterface.NozzleConditions(5.0, 1.0, "HYD40")
    return CEAInterface.get_Cstar(nozzle_cond) isa Float64
end

function test_get_densities()
    nozzle_cond = CEAInterface.NozzleConditions(5.0, 1.0, "HYD40")
    dens = CEAInterface.get_densities(nozzle_cond, 1.5)
    return all(dens[2:end] .< dens[1:(end-1)])    
end

function test_get_exit_mach()
    nozzle_cond = CEAInterface.NozzleConditions(5.0, 1.0, "HYD40")
    return CEAInterface.get_exit_mach(nozzle_cond, 1.5) isa Float64
end

function test_get_sonic_speeds()
    nozzle_cond = CEAInterface.NozzleConditions(5.0, 1.0, "HYD40")
    speeds = CEAInterface.get_sonic_speeds(nozzle_cond, 1.5)
    return all(speeds[2:end] .< speeds[1:(end-1)])
end

function test_get_temperatures()
    nozzle_cond = CEAInterface.NozzleConditions(5.0, 1.0, "HYD40")
    temps = CEAInterface.get_temperatures(
    nozzle_cond, 1.5)
    return all(temps[2:end] .< temps[1:(end-1)])
end

function test_get_exp_ratio()
    nozzle_cond = CEAInterface.NozzleConditions(5.0, 1.0, "HYD40")
    return CEAInterface.get_exp_ratio(nozzle_cond) > 1
end

function test_add_new_propellant()
    CEAInterface.add_new_propellant("N2",
    ['N'], [2], 0.0, 298.15, 1.132e-3)
    ret = false
    try
        nozzle_cond = CEAInterface.NozzleConditions(5.0, 1.0, "N2")
        CEAInterface.get_ambient_Isp(nozzle_cond, 1.5)
        ret = true
    catch
    end
    return ret
end

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
end
end