using Plots, Unitful, CSV, LinearAlgebra
##
function bA(datafile)
    data = CSV.File(joinpath(@__DIR__, "data/", datafile), header = false)
    n=length(data)
    b = data.Column1
    A = [data.Column2 data.Column4 data.Column6]
    return b, A
end
##
struct AFDDataPoint
    label
    A
    F
    D
end

function load_AFD(filename)
    data = CSV.File(joinpath(@__DIR__,"data/", filename), header=false)
    AFDDataPoint.(data.Column1, data.Column2, data.Column4, data.Column6)
end

function calibrate(Fy_series::Vector{AFDDataPoint}, Fx_series::Vector{AFDDataPoint}, d)
    FA = getproperty.(Fy_series, :label)/2
    FF = getproperty.(Fy_series, :label)/2
    FD = getproperty.(Fx_series, :label)

    A = getproperty.(Fy_series, :A)
    F = getproperty.(Fy_series, :F)
    D = getproperty.(Fx_series, :D)

    y_ones = ones(length(Fy_series))
    x_ones = ones(length(Fx_series))

    cA = ([A y_ones] \ FA)*u"g"
    cF = ([F y_ones] \ FF)*u"g"
    cD = ([D x_ones] \ FD)*u"g"

    [
        1 1 0
        0 0 1
        d -d 0u"m"
    ] * [
        diagm(first.([cA, cF, cD])) last.([cA, cF, cD])
    ]
end
##
struct FxFyM
    label
    Fy
    Fx
    M
end

function FxFyM(afd::AFDDataPoint, calib_mat::Matrix)
    FxFyM(
        afd.label,
        (calib_mat[:,1:3] * [
        afd.A
        afd.F
        afd.D
    ] + calib_mat[:,4])...
    )
end

function FxFyM(afds::Vector{AFDDataPoint}, calib_mat::Matrix)
    force_matrix = calib_mat[:,1:3] * [
        getproperty.(afds, :A)'
        getproperty.(afds, :F)'
        getproperty.(afds, :D)'
    ] .+ calib_mat[:,4]
    FxFyM.(
        getproperty.(afds, :label),
        force_matrix[1,:],
        force_matrix[2,:],
        force_matrix[3,:]
    )
end

Ft(f::FxFyM) = √(f.Fx^2+f.Fy^2)

function align_axes_at_90(fxfym::Vector{FxFyM})
    central = findfirst(x->x.label==90, fxfym)

    force_vector = [
        fxfym[central].Fx
        fxfym[central].Fy
    ]

    force_direction = force_vector / norm(force_vector)

    ##alinhar eixo y com direção da força
    ##force_direction = rot_mat * [0;1]
    rot_mat = [
        [force_direction[2]; -force_direction[1]] force_direction
    ]

    ##p rotacionar os pontos, considera-se uma rotação no sentido contrário à rotação dos eixos
    u = unit(fxfym[1].Fx)
    old_fx_fy = ustrip.(u, [
        getproperty.(fxfym, :Fx)'
        getproperty.(fxfym, :Fy)'
    ])

    new_fx_fy = (rot_mat \ old_fx_fy)*u

    acos(force_direction[2]), FxFyM.(getproperty.(fxfym, :label), new_fx_fy[2,:], new_fx_fy[1,:], getproperty.(fxfym, :M))

end

function force_offset_at_90(fxfym::Vector{FxFyM})
    central = findfirst(x->x.label==90, fxfym)
    Fx_offset = fxfym[central].Fx
    M_offset = fxfym[central].M
    d_offset = M_offset / Fx_offset |> u"cm"

    d_offset, FxFyM.(getproperty.(fxfym, :label), getproperty.(fxfym, :Fy),
        getproperty.(fxfym, :Fx) .- Fx_offset, getproperty.(fxfym, :M) .- M_offset)
end

##
FybA_tuples = bA.(
    [
    "Cal_empuxo_Crescente.txt"
    "Cal_empuxo_Decrescente.txt"]
)

Fy_input = cat(first.(FybA_tuples)..., dims=1)
Fy_output = cat(last.(FybA_tuples)..., dims=1)
Fy_seccol = ones(length(Fy_input))
##
FA = Fy_input/2
Acoefs = [Fy_output[:,1] Fy_seccol] \ FA
##
FF = Fy_input/2
Fcoefs = [Fy_output[:,2] Fy_seccol] \ FF
##
FxbA_tuples = bA.(
    [
        "Cal_força_Lateral_Crescente.txt"
        "Cal_força_Lateral_Decrescente.txt"
    ]
)
Fx_input = cat(first.(FxbA_tuples)..., dims=1)
Fx_output = cat(last.(FxbA_tuples)..., dims=1)
Fx_seccol = ones(length(Fx_input))
##
Dcoefs = [Fx_output[:,3] Fx_seccol] \ Fx_input
##
scatter(FA, [Fy_output[:,1] Fy_seccol] * Acoefs)
png("FA_scatter")
##
scatter(FF, [Fy_output[:,2] Fy_seccol] * Fcoefs)
png("FF_scatter")
##
scatter(Fx_input, [Fx_output[:,3] Fx_seccol] * Dcoefs)
png("FD_scatter")
## #####################################################3
scatter(Fy_input, [Fy_output[:,1] Fy_seccol] * Acoefs + [Fy_output[:,2] Fy_seccol] * Fcoefs)
png("Fy_scatter")
##
scatter([Fy_output[:,1] Fy_seccol] * Acoefs - [Fy_output[:,2] Fy_seccol] * Fcoefs)
png("M_scatter")
##
Fy_series = cat(load_AFD.([
    "Cal_empuxo_Crescente.txt"
    "Cal_empuxo_Decrescente.txt"])..., dims=1)
Fx_series = cat(load_AFD.([
    "Cal_força_Lateral_Crescente.txt"
    "Cal_força_Lateral_Decrescente.txt"])..., dims=1)
##
calib_mat = calibrate(Fy_series, Fx_series, 16.5u"mm")
##
thrust_data = load_AFD("empuxo_sem_aleta.txt")
n = length(thrust_data)
thrust = calib_mat[:,1:3] * [
    getproperty.(thrust_data, :A)'
    getproperty.(thrust_data, :F)'
    getproperty.(thrust_data, :D)'
] .+ calib_mat[:,4]
##
thrust = FxFyM(thrust_data, calib_mat)
##
plot(ustrip.(u"g", getproperty.(thrust, :Fy)))
##
#plots
files = readdir(joinpath(@__DIR__, "data/"))
files = filter(fname -> fname[1:3] == "exp", files)
exp_numbers = [parse(Int, fname[4:(2+findfirst(!isdigit, fname[4:end]))]) for fname in files]
files = files[exp_numbers .>= 7]
##
exps = load_AFD.(files)
##
function full_plot(forces::Vector{FxFyM}, fname, f_unit = u"g", m_unit=u"g*cm")
    p = scatter( getproperty.(forces, :label), ustrip.(f_unit,    getproperty.(forces, :Fy)), label="Fy (g)", legend=:outertopright)
    scatter!(p, getproperty.(forces, :label), ustrip.(f_unit,    getproperty.(forces, :Fx)), label="Fx (g)", dpi=400)
    scatter!(p, getproperty.(forces, :label), ustrip.(m_unit, getproperty.(forces, :M)), label="M (g*cm)")
    title!(p, fname[1:(end-4)])
    p
end
##
for (file, exp) in zip(files, exps)
    forces = FxFyM(exp, calib_mat)
    p = full_plot(forces, file)
    png(p, joinpath(@__DIR__, "output/"*file)[1:(end-4)])
end
##
#hipótese 1 - o aparato estava rotacionado de um ângulo theta (não explica momento != 0)
#rotate correction
thetas = []
for (file, exp) in zip(files, exps)
    forces = FxFyM(exp, calib_mat)
    theta, rot_for = align_axes_at_90(forces)
    push!(thetas, theta)
    p = full_plot(rot_for, file)
    plot!(p, getproperty.(rot_for, :label), ustrip.(u"g",Ft.(rot_for)), label = "total")
    png(p, joinpath(@__DIR__, "output/rotated_"*file[1:(end-4)]))
end

##
#hipótese 2 - o aparato estava alinhado, e havia um Fx causando momento
#boa!!!
arms = []
for (file, exp) in zip(files, exps)
    forces = FxFyM(exp, calib_mat)
    d, offset_for = force_offset_at_90(forces)
    push!(arms, d)
    p = full_plot(offset_for, file)
    png(p, joinpath(@__DIR__, "output/offset_"*file[1:(end-4)]))
end

## TODO
#find center of forces, correlate with metal sheet position
#get control derivatives