file = joinpath(pwd(),"data.xlsx")
function gen_lowlevel(high_level_des)
	weeks = 1
	days = 7
    num_day_week = 7
    horizon = days*24
    V_max = high_level_des["V_max"] 
	X_max = high_level_des["X_max"] 
    
    opt_val = 0
	for i in 1:weeks
        task = DataFrame(XLSX.readtable(file,"Tasks"))
        resources = DataFrame(XLSX.readtable(file,"Resources"))
        network = DataFrame(XLSX.readtable(file,"Network"))
        supply = []
        sp = DataFrame(XLSX.readtable(file,"Supply"))
        push!(supply,sp)
        days = 7
        num_day_week = 7
        horizon = days*24
        data = create_model_data(task, resources, network, supply, horizon,days,num_day_week)
        RTN_model= RTN(data)
        opt = solve_model_full(RTN_model,0,V_max,X_max)
        #opt = solve_model_full(RTN_model)
        opt_val = opt_val+opt
    end
    # Create DataFrame
    return opt_val/weeks
end
