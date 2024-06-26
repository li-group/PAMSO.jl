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

root = pwd()
function gen_lowlevel(high_level_des)
	weeks = 1
	days = 7
    num_day_week = 7
    horizon = days*24
    V_max = high_level_des["V_max"] 
	X_max = high_level_des["X_max"] 
    file = joinpath(root,"RTN", "case_7_daysn_3.xlsx")
    opt_val = 0
	for i in 1:weeks
        task = DataFrame(XLSX.readtable(file,"Tasks"))
        resources = DataFrame(XLSX.readtable(file,"Resources"))
        network = DataFrame(XLSX.readtable(file,"Network"))
        supply = []
        sp = DataFrame(XLSX.readtable(file,"Supply_"*string(4)))
        push!(supply,sp)
        days = 7
        num_day_week = 7
        horizon = days*24
        data = create_model_data(task, resources, network, supply, horizon,days,num_day_week)
        RTN_model= RTN(data)
        opt = solve_model_full(RTN_model,V_max,X_max,"week4_results.xlsx")
        #opt = solve_model_full(RTN_model)
        opt_val = opt_val+opt
    end
    # Create DataFrame
    return opt_val/weeks
end