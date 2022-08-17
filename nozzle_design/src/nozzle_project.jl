module NozzleProject
using ..CEAInterface
using ..Unitful
struct CEACoeffs
    eps::Float64
    Cstar::Quantity
    Cf::Float64
end

function CEACoeffs(ncond::OperatingCondition)
    eps = CEAInterface.get_exp_ratio(ncond)
    Cstar = CEAInterface.get_Cstar(ncond) * 1u"m/s"
    Cf = CEAInterface.get_ambient_Cf(ncond, eps)[2]
    return CEACoeffs(eps, Cstar, Cf)
end
export get_mdot
function get_mdot(F::Quantity, ncond::OperatingCondition)
    coeffs = CEACoeffs(ncond)
    return uconvert(u"kg/s", F / (coeffs.Cf * coeffs.Cstar))
end

export NozzleAreas
struct NozzleAreas
    Achamber::Quantity
    Athroat::Quantity
    Aexit::Quantity
end

function NozzleAreas(F::Quantity, ncond::OperatingCondition;
    contraction_ratio::Float64 = 10.0,
    min_chamber_radius::Quantity = 0.0u"mm")

    coeffs = CEACoeffs(ncond)
    At = uconvert(u"mm^2", (F / (ncond.Pc * coeffs.Cf)))   #mm²
    Ae = At * coeffs.eps    #mm²
    Ac = max(At * contraction_ratio, π*min_chamber_radius^2) #mm²
    return NozzleAreas(Ac, At, Ae)
end

export get_radii, get_radius
get_radius(A) = √(A/π)
get_radii(noz::NozzleAreas)= get_radius(noz.Achamber),
                                get_radius(noz.Athroat),
                                get_radius(noz.Aexit)
export NozzleGeometry
struct NozzleGeometry
    areas::NozzleAreas
    exit_half_angle::Quantity
    conv_half_angle::Quantity
    chamber_length::Quantity
    thickness::Quantity
end

get_radii(noz::NozzleGeometry) = get_radii(noz.areas)
export round_flow_wall
function round_flow_wall(noz::NozzleGeometry)
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
            (rchamber - rthroat) / tan(noz.conv_half_angle)
            (rexit - rthroat) / tan(noz.exit_half_angle) 
        ]), dims=1)
end

export pipe_speed
function pipe_speed(mdot::Quantity, opcond::OperatingCondition, pipe_diam::Quantity)
    uconvert(u"m/s",
    mdot * 8.314u"J/K/mol" *
         opcond.propellant.temperature /
          (π * (pipe_diam/2) ^ 2 * opcond.Pc *
                         opcond.propellant.molar_mass)
    )
end

end