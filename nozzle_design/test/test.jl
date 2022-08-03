using Test
module RocketCeaTest
using PyCall
function test_rocket_cea()
    cea_obj = pyimport("rocketcea.cea_obj")
    C = cea_obj.CEA_Obj(oxName="LOX", fuelName="LH2")
    return C.get_Isp()
end
end
@test RocketCeaTest.test_rocket_cea() ≈ 374.30361765576265