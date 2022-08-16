"Interface com o RocketCEA para tubeiras de gás frio"
module CEAInterface
using ..Unitful
using PyCall
const CEA_OBJ       = pyimport("rocketcea.cea_obj")
const CEA_OBJ_UNITS = pyimport("rocketcea.cea_obj_w_units")
const CEA_UNITS     = pyimport("rocketcea.units")

#colocar unidades SI
CEA_UNITS.add_user_units("millipoise", "Pa-s", 1e4)
CEA_UNITS.add_user_units("mcal/cm-K-s", "W/m-degC", 4.184e-3*1e-2)

function add_new_gas_monoprop(name::String, temperature_K::Float64)
    card = "
    name $name  wt%=100.00  t(k)=$temperature_K
    "
    CEA_OBJ.add_new_propellant(name, card)
end
import Base.show

export Propellant
struct Propellant
    name::String
    molar_mass::Quantity
    temperature::Quantity
end

function Base.show(io::IO, mime::MIME"text/plain", p::Propellant)
    print(io, p.name * " (MM = " * string(p.molar_mass) * ") @ T = " * string(p.temperature))
end

#câmara infinita
export OperatingCondition
struct OperatingCondition
    Pc::Quantity
    Pamb::Quantity
    propellant::Propellant
    cea_obj::PyObject
    function OperatingCondition(Pc::Quantity,
                        Pamb::Quantity,
                        propellant::Propellant
    )
        add_new_gas_monoprop(propellant.name,
                ustrip(Float64, u"K", propellant.temperature))
        new(Pc, Pamb, propellant,
            CEA_OBJ_UNITS.CEA_Obj(
                propName=propellant.name,
                isp_units            = "sec",
                cstar_units          = "m/sec",
                pressure_units       = "kPa",
                temperature_units    = "K",
                sonic_velocity_units = "m/sec",
                enthalpy_units       = "kJ/kg",
                density_units        = "kg/m^3",
                specific_heat_units  = "kJ/kg-K",
                viscosity_units      = "Pa-s",
                thermal_cond_units   = "W/m-degC"
            )
        )
    end
end

Base.show(io::IO, mime::MIME"text/plain", opcond::OperatingCondition) = begin
    print(io, "$(opcond.propellant) " * ", Pchamber = $(opcond.Pc), Pambient = $(opcond.Pamb)")
end


#(Isp, condição::String)
function get_ambient_Isp(opcond::OperatingCondition,
                                 exp_ratio::Float64) ::Tuple
    #considera λ?
    return opcond.cea_obj.estimate_Ambient_Isp(
        Pc=ustrip(Float64, u"kPa", opcond.Pc), 
        eps=exp_ratio, 
        Pamb=ustrip(Float64, u"kPa", opcond.Pamb)
    )
end

# CFcea,CFfrozen, mode
function get_ambient_Cf(opcond::OperatingCondition,
                                exp_ratio::Float64) ::Tuple
    return opcond.cea_obj.getFrozen_PambCf(
        Pamb=ustrip(Float64, u"kPa", opcond.Pamb),
        Pc=ustrip(Float64, u"kPa", opcond.Pc),
        eps=exp_ratio
    )
end

function get_Cstar(opcond::OperatingCondition) :: Float64
    return opcond.cea_obj.get_Cstar(
        Pc=ustrip(Float64, u"kPa", opcond.Pc))
end

#vector chamber, throat, exit
function get_densities(opcond::OperatingCondition,
    exp_ratio::Float64) :: Vector{Float64}
    return opcond.cea_obj.get_Densities(
        Pc=ustrip(Float64, u"kPa", opcond.Pc),
        eps=exp_ratio
    )
end

function get_exit_mach(opcond::OperatingCondition,
    exp_ratio::Float64) :: Float64
    return opcond.cea_obj.get_MachNumber(
        Pc=ustrip(Float64, u"kPa", opcond.Pc),
        eps=exp_ratio
    )
end

function get_sonic_speeds(opcond::OperatingCondition,
    exp_ratio::Float64) ::Vector{Float64}
    return opcond.cea_obj.get_SonicVelocities(
        Pc=ustrip(Float64, u"kPa", opcond.Pc),
        eps=exp_ratio
    )
end

function get_temperatures(opcond::OperatingCondition,
    exp_ratio::Float64) :: Vector{Float64}
    return opcond.cea_obj.get_Temperatures(
        Pc=ustrip(Float64, u"kPa", opcond.Pc),
        eps=exp_ratio
    )
end

function get_exp_ratio(opcond::OperatingCondition) :: Float64
    return opcond.cea_obj.get_eps_at_PcOvPe(
        Pc=ustrip(Float64, u"kPa", opcond.Pc),
        PcOvPe=ustrip(Float64, u"kPa", opcond.Pc)/ustrip(Float64, u"kPa", opcond.Pamb)
    )
end

end