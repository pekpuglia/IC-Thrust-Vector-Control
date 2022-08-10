"Interface com o RocketCEA para tubeiras de gás frio"
module CEAInterface
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

#câmara infinita
struct OperatingCondition
    Pc::Float64
    Pamb::Float64
    propellant::String
    cea_obj::PyObject
    function OperatingCondition(Pc::Real,
                Pamb::Real,
                propellant::String
                )
        new(Pc, Pamb, propellant,
            CEA_OBJ_UNITS.CEA_Obj(
                propName=propellant,
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

function OperatingCondition(Pc::Real,
    Pamb::Real,
    propellant::String,
    propellant_temperature::Real
    )
    add_new_gas_monoprop(propellant,
            propellant_temperature)
    OperatingCondition(Pc, Pamb, propellant)
end
import Base.show

Base.show(io::IO, mime::MIME"text/plain", opcond::OperatingCondition) = begin
    print(io, "$(opcond.propellant) " * "Pchamber = $(opcond.Pc), Pambient = $(opcond.Pamb)")
end


#(Isp, condição::String)
function get_ambient_Isp(nozzle_cond::OperatingCondition,
                                 exp_ratio::Float64) ::Tuple
    #considera λ?
    return nozzle_cond.cea_obj.estimate_Ambient_Isp(
        Pc=nozzle_cond.Pc, 
        eps=exp_ratio, 
        Pamb=nozzle_cond.Pamb)
end

# CFcea,CFfrozen, mode
function get_ambient_Cf(nozzle_cond::OperatingCondition,
                                exp_ratio::Float64) ::Tuple
    return nozzle_cond.cea_obj.getFrozen_PambCf(
        Pamb=nozzle_cond.Pamb,
        Pc=nozzle_cond.Pc,
        eps=exp_ratio
    )
end

function get_Cstar(nozzle_cond::OperatingCondition) :: Float64
    return nozzle_cond.cea_obj.get_Cstar(
        Pc=nozzle_cond.Pc)
end

#vector chamber, throat, exit
function get_densities(nozzle_cond::OperatingCondition,
    exp_ratio::Float64) :: Vector{Float64}
    return nozzle_cond.cea_obj.get_Densities(
        Pc=nozzle_cond.Pc,
        eps=exp_ratio
    )
end

function get_exit_mach(nozzle_cond::OperatingCondition,
    exp_ratio::Float64) :: Float64
    return nozzle_cond.cea_obj.get_MachNumber(
        Pc=nozzle_cond.Pc,
        eps=exp_ratio
    )
end

function get_sonic_speeds(nozzle_cond::OperatingCondition,
    exp_ratio::Float64) ::Vector{Float64}
    return nozzle_cond.cea_obj.get_SonicVelocities(
        Pc=nozzle_cond.Pc,
        eps=exp_ratio
    )
end

function get_temperatures(nozzle_cond::OperatingCondition,
    exp_ratio::Float64) :: Vector{Float64}
    return nozzle_cond.cea_obj.get_Temperatures(
        Pc=nozzle_cond.Pc,
        eps=exp_ratio
    )
end

function get_exp_ratio(nozzle_cond::OperatingCondition) :: Float64
    return nozzle_cond.cea_obj.get_eps_at_PcOvPe(
        Pc=nozzle_cond.Pc,
        PcOvPe=nozzle_cond.Pc/nozzle_cond.Pamb
    )
end

end