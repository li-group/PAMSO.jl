root = pwd()
include(joinpath(root,"data_utils.jl"))
include(joinpath(root,"rtn_model_full.jl"))
include(joinpath(root,"rtn_agg.jl"))


import XLSX
import CSV
using DataFrames

file = joinpath(pwd(),"data.xlsx")
task = DataFrame(XLSX.readtable(file,"Tasks"))
resources = DataFrame(XLSX.readtable(file,"Resources"))
network = DataFrame(XLSX.readtable(file,"Network"))
supply = []
weeks = 4
for i in range(1,weeks)
    sp = DataFrame(XLSX.readtable(file,"Supply_"*string(i)))
    push!(supply,sp)
end
days = 7*weeks
num_day_week = 7
horizon = days*24
data = create_model_data(task, resources, network, supply, horizon,days,num_day_week)
RTN_model= RTN(data)
fs_model = solve_model_full(RTN_model,1)
