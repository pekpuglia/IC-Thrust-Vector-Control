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