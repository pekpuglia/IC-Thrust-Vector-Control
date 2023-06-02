using Plots, Unitful, CSV
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

function calibrate(Fy_series::Vector{AFDDataPoint}, Fx_series::Vector{AFDDataPoint})
    FA = getproperty.(Fy_series, :label)/2
    FF = getproperty.(Fy_series, :label)/2
    FD = getproperty.(Fx_series, :label)

    

end
##
struct FxFyM
    label
    Fy
    Fx
    M
end

function FxFyM(afd::AFDDataPoint, coefs::Matrix)
end

function FxFyM(afds::Vector, coefs::Matrix)
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