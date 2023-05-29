using Plots, Unitful, CSV
##
##
#juntar as curvas de subida e descida
thrust_data = CSV.File("./2dof_test/data/Cal_empuxo_Crescente.txt", header=false)
##
plot(thrust_data.Column1, thrust_data.Column2)
plot!(thrust_data.Column1, thrust_data.Column4)
plot!(thrust_data.Column1, thrust_data.Column6)
##
#fitar ax + b p cada coluna
A = [ones(size(thrust_data.Column2)) thrust_data.Column2]
b = thrust_data.Column1
coefs = A \ b
##
plot!(A * coefs, thrust_data.Column2)