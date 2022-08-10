using Plots
include("../src/nozzle_design.jl")
##

function mdot(Pchamber::Float64, F::Float64)
    ncond = CEAInterface.OperatingCondition(Pchamber, 1.0, "N2", 298.15)
    return get_nozzle_mdot(F, ncond)
end
##
Pchambers = 1.1:0.1:10.0
Fs = 0.1:0.1:20.0
mdots = mdot.(Pchambers', Fs)
##

contour(Pchambers, Fs, mdots, levels = 20, fill=true)
xlabel!("Chamber pressure (atm)")
ylabel!("Thrust (N)")
title!("Mass flow (kg/s)")