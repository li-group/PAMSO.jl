#include("data_utils.jl")
root = pwd()
include(joinpath(root,"RTN","data_utils1.jl"))
include(joinpath(root,"RTN","rtn_model_gp2.jl"))
include(joinpath(root,"RTN","rtn_agg_gp2.jl"))

import XLSX
import CSV
using DataFrames
using Dates
#RTN_model= RTN(data, "baron")
#opt = RTN_model.solve_model()

function gen_highlevel(p_val)
	file = joinpath(root,"RTN", "case_7_daysn_3.xlsx")
    #xf = XLSX.readxlsx(joinpath(root,"data", "case_7_daysn.xlsx"))
    task = DataFrame(XLSX.readtable(file,"Tasks"))
    resources = DataFrame(XLSX.readtable(file,"Resources"))
    network = DataFrame(XLSX.readtable(file,"Network"))
    supply = []
    weeks = 1
    for i in range(1,weeks)
        sp = DataFrame(XLSX.readtable(file,"Supply_"*string(4)))
        push!(supply,sp)
    end
    days = 7
    num_day_week = 7
    horizon = days*24
    data = create_model_data(task, resources, network, supply, horizon,days,num_day_week)
    

    
    RTN_agg_model = RTN_agg(data)
    opt,V_max,X_max = solve_model_agg(RTN_agg_model,p_val)
    high_level_des=Dict()
	high_level_des["V_max"] = V_max
	high_level_des["X_max"] = X_max
	
	return high_level_des
end
