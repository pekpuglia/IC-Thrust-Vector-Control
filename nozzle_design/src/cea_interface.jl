"Interface com o RocketCEA para tubeiras de gás frio"
module CEAInterface
using PyCall
const CEA_OBJ       = pyimport("rocketcea.cea_obj")
const CEA_OBJ_UNITS = pyimport("rocketcea.cea_obj_w_units")
const CEA_UNITS     = pyimport("rocketcea.units")

#colocar unidades SI
CEA_UNITS.add_user_units("millipoise", "Pa-s", 1e4)
CEA_UNITS.add_user_units("mcal/cm-K-s", "W/m-degC", 4.184e-3*1e-2)

#câmara infinita
struct NozzleConditions
    Pc::Float64
    Pamb::Float64
    propellant::String
    cea_obj::PyObject
    function NozzleConditions(Pc::Real,
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

#(Isp, condição::String)
function get_ambient_Isp(nozzle_cond::NozzleConditions,
                                 exp_ratio::Float64)
    #considera λ?
    return nozzle_cond.cea_obj.estimate_Ambient_Isp(
        Pc=nozzle_cond.Pc, 
        eps=exp_ratio, 
        Pamb=nozzle_cond.Pamb)
end

# CFcea,CFfrozen, mode
function get_ambient_Cf(nozzle_cond::NozzleConditions,
                                exp_ratio::Float64)
    return nozzle_cond.cea_obj.getFrozen_PambCf(
        Pamb=nozzle_cond.Pamb,
        Pc=nozzle_cond.Pc,
        eps=exp_ratio
    )
end

function get_Cstar(nozzle_cond::NozzleConditions)
    return nozzle_cond.cea_obj.get_Cstar(
        Pc=nozzle_cond.Pc)
end

#vector chamber, throat, exit
function get_densities(nozzle_cond::NozzleConditions,
    exp_ratio::Float64)
    return nozzle_cond.cea_obj.get_Densities(
        Pc=nozzle_cond.Pc,
        eps=exp_ratio
    )
end

function get_exit_mach(nozzle_cond::NozzleConditions,
    exp_ratio::Float64)
    return nozzle_cond.cea_obj.get_MachNumber(
        Pc=nozzle_cond.Pc,
        eps=exp_ratio
    )
end

function get_sonic_speeds(nozzle_cond::NozzleConditions,
    exp_ratio::Float64)
    return nozzle_cond.cea_obj.get_SonicVelocities(
        Pc=nozzle_cond.Pc,
        eps=exp_ratio
    )
end

function get_temperatures(nozzle_cond::NozzleConditions,
    exp_ratio::Float64)
    return nozzle_cond.cea_obj.get_Temperatures(
        Pc=nozzle_cond.Pc,
        eps=exp_ratio
    )
end

function get_exp_ratio(nozzle_cond::NozzleConditions)
    return nozzle_cond.cea_obj.get_eps_at_PcOvPe(
        Pc=nozzle_cond.Pc,
        PcOvPe=nozzle_cond.Pc/nozzle_cond.Pamb
    )
end

function add_new_propellant(name::String,
    elements::Vector{Char}, amounts::Vector{Int},
    enthalpy_cal::Float64, temperature_K::Float64,
    rho_grams_cm3::Float64)
    card = "
    name $name " * prod("$el $am " for (el, am) in zip(elements, amounts)) * "wt%=100.00
    h,cal=$enthalpy_cal     t(k)=$temperature_K  rho.g/cc=$rho_grams_cm3
    "
    CEA_OBJ.add_new_propellant(name, card)
end

end