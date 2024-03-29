using Revise
using GLMakie
using ConstructiveGeometry
using Plots
##
include("../src/nozzle_design.jl")
using .NozzleDraw
##
required_thrust = 2.0u"N" #N
#deveria ser 600?
chamber_pressure = 500.0u"kPa"  #kPa
prop_temperature = 298.15u"K"
conn_diam = 11u"mm"   #mm
##
propellant = CEAInterface.Propellant("Air", 29.8u"g/mol", prop_temperature)

opcond = CEAInterface.OperatingCondition(chamber_pressure,
                100.0u"kPa", propellant)

areas = NozzleProject.NozzleAreas(required_thrust, opcond, 
                contraction_ratio=50.0, min_chamber_radius = 15u"mm")


nozzle_geom = RoundNozzle(areas, 5.0u"°", 30.0u"°", 30.0u"mm", 3.0u"mm")
                
##
#verify speed in tube
mdot = NozzleProject.get_mdot(required_thrust, opcond)
NozzleProject.pipe_speed(mdot, opcond, 10u"mm")
##

base_pads = [
    Pad(
        2*conn_diam,
        10u"mm"+2*conn_diam,
        nozzle_geom.thickness,
        -nozzle_geom.thickness,
        angle*u"°"
    )
    for angle in 0:90:270
]

gas_hole = SideHole(
    2*conn_diam,
    2*conn_diam,
    nozzle_geom.thickness,
    10u"mm" - nozzle_geom.thickness,
    90u"°",
    conn_diam
)

nozzle1 = build_nozzle(nozzle_geom, base_pads..., gas_hole)
##
NozzleDraw.export_stl("./nozzle_design/geometry/iter5/nozzle_2N_elongated.stl", nozzle1, rtol=1e-3, atol=1e-3)
##
probed_nozzle = build_nozzle(nozzle_geom, base_pads..., gas_hole, 
                SideHole(2*conn_diam, 
                        2*conn_diam, 
                        nozzle_geom.thickness,
                        10u"mm" - nozzle_geom.thickness,
                        0u"°",
                        conn_diam))

NozzleDraw.export_stl("./nozzle_design/geometry/iter5/nozzle_2N_probed.stl", probed_nozzle, rtol=1e-3, atol=1e-3)

##
#encaixe na bancada de empuxo
filled_motor = union(nozzle1, 
    [0,0,-mm(nozzle_geom.thickness)] 
    + linear_extrude(10) 
    * circle(
        mm(
            NozzleDraw.get_radius(nozzle_geom.areas.Achamber)
            + nozzle_geom.thickness
        ) + 1e-2
    )
)
t = mm(nozzle_geom.thickness)
nozzle_OD = mm(2*NozzleDraw.get_radius(nozzle_geom.areas.Achamber)) + 2t

#recesso do motor
nozzle_support = union(linear_extrude(15) * square(nozzle_OD + 4t, center=true) \
             ([0, 0, 5 + NozzleDraw.mm(nozzle_geom.thickness)] + filled_motor),
             [0, 0, -20] + linear_extrude(20) * polygon(NozzleDraw.poly(20, 6))
)
             

##
NozzleDraw.export_stl("./nozzle_design/geometry/iter5/support.stl", nozzle_support, rtol=1e-2, atol=1e-2)
##
#export de figuras pro rela
img_path = joinpath(pwd(), "report", "img")
##
#perfil
wall = NozzleDraw.flow_wall(nozzle_geom)
p = Plots.plot(wall .|> first .|> ustrip, wall .|> last .|> ustrip,
    aspect_ratio=:equal,
    label="",
    xlabel="Raio (mm)",
    ylabel="Comprimento (mm)",
    dpi=400)
png(p, joinpath(img_path, "internal_profile.png"))
##
using Latexify, UnitfulLatexify
##
#parâmetros propulsivos
coeffs = NozzleProject.CEACoeffs(opcond)
cea_eps = latexify("ε = $(coeffs.eps)", fmt = "%.2f")
cea_cstar = latexify(coeffs.Cstar)
cea_cf = latexify("C_F = $(coeffs.Cf)", fmt="%.2f")
rela_mdot = latexify(mdot |> u"g/s")
##
#validação
using MAT, Statistics
##
data = matread(joinpath(pwd(), "1dof_test", "data", "iter5", "test2_callibrated.mat"))["mat"]
F = first.(data)u"g" * 9.79u"m/s^2" .|> u"N" 
P1 = last.(data)u"bar"
##
p = Plots.scatter(P1 .|> ustrip, F .|> ustrip,
    label="",
    xlabel="Pressão de câmara (bar)",
    ylabel="Empuxo (N)",
    dpi=400)
png(p, joinpath(img_path, "thrust_vs_chamber_pressure.png"))
##
#parâmetros propulsivos
CF_emp = F ./ (P1 * areas.Athroat) .|> NoUnits
mean_CF_emp = mean(CF_emp)
sigma_CF_emp = std(CF_emp)
##
true_mdots = NozzleProject.get_mdot.(F, CEAInterface.OperatingCondition.(P1, 100.0u"kPa", Ref(propellant)))
##
Cstar_emp = (P1 * areas.Athroat) ./ true_mdots .|> u"m/s"
mean_Cstar_emp = mean(Cstar_emp)
sigma_Cstar_emp = std(Cstar_emp)
##
Findex = findmin(x -> abs(x-2u"N"), F)[2]
Isp_emp = F[Findex] ./ (9.80665u"m/s^2" * true_mdots[Findex]) |> u"s"