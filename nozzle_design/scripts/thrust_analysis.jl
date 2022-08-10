using Plots
include("../src/nozzle_design.jl")
##
Pchambers = 150.0:50:1000
Fs = 0.1:0.1:20.0
mdots = get_nozzle_mdot.(Fs, CEAInterface.OperatingCondition.(Pchambers', 100.0, "N2", 298.15))
##
contour(Pchambers, Fs, mdots, levels = 20, fill=true)
xlabel!("Chamber pressure")
ylabel!("Thrust (N)")
title!("Mass flow (kg/s)")
png("./nozzle_design/scripts/thust_analysis.png")
##
ncond = CEAInterface.OperatingCondition(500.0, 100.0, "N2", 298.15)
coeffs = CEACoeffs(ncond)
mdot = get_nozzle_mdot(5.0, ncond)
display(ncond)
dump(coeffs)
println("m_dot = $mdot")