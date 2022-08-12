module NozzleProject
using ..CEAInterface
struct CEACoeffs
    eps::Float64
    Cstar::Float64
    Cf::Float64
end

function CEACoeffs(ncond::OperatingCondition)
    eps = CEAInterface.get_exp_ratio(ncond)
    Cstar = CEAInterface.get_Cstar(ncond)
    Cf = CEAInterface.get_ambient_Cf(ncond, eps)[2]
    return CEACoeffs(eps, Cstar, Cf)
end
export get_mdot
function get_mdot(F::Float64, ncond::OperatingCondition)
    coeffs = CEACoeffs(ncond)
    return F / (coeffs.Cf * coeffs.Cstar)
end

export NozzleAreas
struct NozzleAreas
    Achamber::Float64
    Athroat::Float64
    Aexit::Float64
end

function NozzleAreas(F::Float64, ncond::OperatingCondition;
    contraction_ratio::Float64 = 10.0,
    min_chamber_radius_mm::Float64 = 0.0)

    coeffs = CEACoeffs(ncond)
    At = 1e6*(F / (1e3*ncond.Pc * coeffs.Cf))   #mm²
    Ae = At * coeffs.eps    #mm²
    Ac = max(At * contraction_ratio, π*min_chamber_radius_mm^2) #mm²
    return NozzleAreas(Ac, At, Ae)
end

export get_radii, get_radius
get_radius(A::Float64) = √(A/π)
get_radii(noz::NozzleAreas)= get_radius(noz.Achamber),
                                get_radius(noz.Athroat),
                                get_radius(noz.Aexit)
export NozzleGeometry
struct NozzleGeometry
    areas::NozzleAreas
    exit_half_angle::Float64
    conv_half_angle::Float64
    chamber_length::Float64
    thickness::Float64
end

get_radii(noz::NozzleGeometry) = get_radii(noz.areas)
export generate_flow_wall
function generate_flow_wall(noz::NozzleGeometry)
    rchamber, rthroat, rexit = get_radii(noz)

    return cat.([
        rchamber
        rchamber
        rthroat
        rexit
    ],
        accumulate(+, [
            0
            noz.chamber_length
            (rchamber - rthroat) / tand(noz.conv_half_angle)
            (rexit - rthroat) / tand(noz.exit_half_angle) 
        ]), dims=1)
end

end