root = pwd()
include(joinpath(root,"data_utils.jl"))
include(joinpath(root,"rtn_model_full.jl"))
include(joinpath(root,"rtn_agg.jl"))

import XLSX
import CSV
using DataFrames
using JuMP
using Gurobi

file = joinpath(pwd(),"data.xlsx")
function gen_highlevel(p_val)
    task = DataFrame(XLSX.readtable(file,"Tasks"))
    resources = DataFrame(XLSX.readtable(file,"Resources"))
    network = DataFrame(XLSX.readtable(file,"Network"))
    supply = []
    weeks = 1
    for i in range(1,weeks)
        sp = DataFrame(XLSX.readtable(file,"Supply"))
        push!(supply,sp)
    end
    days = 3
    num_day_week = 3
    horizon = days*24
    data = create_model_data(task, resources, network, supply, horizon,days,num_day_week)
    

    
    RTN_agg_model = RTN_agg(data)
    opt,V_max,X_max = solve_model_agg(RTN_agg_model,p_val)
    high_level_des=Dict()
	high_level_des["V_max"] = V_max
	high_level_des["X_max"] = X_max
	
	return high_level_des
end
