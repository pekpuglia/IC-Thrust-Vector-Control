using Plots, Unitful, CSV
##
function bA(datafile, b_column)
    data = CSV.File(joinpath(@__DIR__, "data/", datafile), header = false)
    n=length(data)
    b = zeros(n, 3)
    b[:, b_column] .= data.Column1
    A = [data.Column2 data.Column4 data.Column6 ones(n,1)]
    return b, A
end
##
bA_tuples = bA.(
    [
    "Cal_empuxo_Crescente.txt"
    "Cal_empuxo_Decrescente.txt"
    "Cal_força_Lateral_Crescente.txt"
    "Cal_força_Lateral_Decrescente.txt"], [1, 1, 2, 2]) 

#[Fy Fx M]
b = cat(first.(bA_tuples)..., dims=1)
A = cat(last.(bA_tuples)..., dims=1)
##
#[Fy Fx M] = [A F D 1] coefs
coefs = A \ b
##
#calib do momento

##
scatter(b[:, 2], A * coefs[:,2], label="")
plot!(identity, b[:, 2], line=:dash, color=:red, label="")
##
struct AFDDataPoint
    label
    A
    F
    D
end

function load_AFD(filename)
    data = CSV.File(joinpath(@__DIR__,"data/", filename), header=false)
    ret = (data.Column2, data.Column4, data.Column6)
    AFDDataPoint.(data.Column1, data.Column2, data.Column4, data.Column6)
end

struct FxFyM
    label
    Fy
    Fx
    M
end

function FxFyM(afd::AFDDataPoint, coefs::Matrix)
    FxFyM(afd.label, ([afd.A afd.F afd.D 1] * coefs)...)
end

function FxFyM(afds::Vector, coefs::Matrix)
    fyfxm = eachrow([getproperty.(afds, [:A :F :D]) ones(length(afds))] * coefs)
    FxFyM.(getproperty.(afds, :label), getindex.(fyfxm,1), getindex.(fyfxm,2), getindex.(fyfxm,3))
end

Ft(f::FxFyM) = √(f.Fx^2+f.Fy^2)

Base.getproperty(x::Vector{FxFyM}, s::Symbol) = getproperty.(x, s)
##
#teste com empuxo sem aleta
raw_thrustAFD = load_AFD("empuxo_sem_aleta.txt")
##
raw_thrustFxFy = FxFyM(raw_thrustAFD, coefs)
##
p = scatter(Ft.(raw_thrustFxFy), label="", xlabel="Medida", ylabel="Força (g)", title="Empuxo sem aleta", dpi=400)
vline!(p, findall(x -> x > 0, diff(raw_thrustFxFy.label)), line = :dash, label = "")
png(p, joinpath(@__DIR__, "output/", "empuxo_sem_aleta.png"))
##
exp7AFD = load_AFD("exp6_maxbar_5_em5.txt")
##
exp7FxFyM = FxFyM(exp7AFD, coefs)
##
plot(exp7FxFyM.label, Ft.(exp7FxFyM))