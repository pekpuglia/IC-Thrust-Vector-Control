include("cea_interface.jl")

struct CEACoeffs
    eps::Float64
    Cstar::Float64
    Cf::Float64
end

function CEACoeffs(ncond::CEAInterface.OperatingCondition)
    eps = CEAInterface.get_exp_ratio(ncond)
    Cstar = CEAInterface.get_Cstar(ncond)
    Cf = CEAInterface.get_ambient_Cf(ncond, eps)[2]
    return CEACoeffs(eps, Cstar, Cf)
end

function get_nozzle_mdot(F::Float64, ncond::CEAInterface.OperatingCondition)
    coeffs = CEACoeffs(ncond)
    return F / (coeffs.Cf * coeffs.Cstar)
end

struct NozzleAreas
    Achamber::Float64
    Athroat::Float64
    Aexit::Float64
end

function NozzleAreas(F::Float64, ncond::CEAInterface.OperatingCondition,
            contraction_ratio::Float64 = 10.0)
    coeffs = CEACoeffs(ncond)
    At = F / (ncond.Pc * coeffs.Cf)
    Ae = At * coeffs.eps
    Ac = At * contraction_ratio
    return NozzleAreas(Ac, At, Ae)
end