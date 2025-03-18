using Dates
using DataFrames
using CSV
using Statistics
using Clustering
using FileIO
using JuMP
import Gurobi
import XLSX
root = pwd()


rootn = pwd()
cd(root)
include(joinpath(rootn,"data","Preprocess_input.jl"))
#include(joinpath(root,"Preprocess_input.jl"))
using Serialization
#FileIO.save("P1.jld2","P1",P)
include(joinpath(root,"data","calc_dist.jl"))
include(joinpath(root,"data","datagen.jl"))
include(joinpath(root,"model_mod_multi.jl"))
include(joinpath(root,"rl_agg_og_multi.jl"))

function gen_highlevel(p_val)
	df_loc = DataFrame(CSV.File(df_loc_path))
	n_loc_og = 200
	n_u = 22
	n_loc = n_loc_og
	trline = []
	Location = []
	Location_tr = []
	Location_u = []
	n_bun = Dict()
	for i = 1:n_loc_og
		push!(Location_tr,"r"*string(i))
	  	push!(Location,"r"*string(i))
	end
	for i = 1:n_u
		push!(Location_tr,"ru"*string(i))
		push!(Location_u,"ru"*string(i))
	end
	dist = cal_dist(df_loc)
	for i = 1:n_loc+n_u
	  for j = 1:n_loc+n_u
	    if (i != j && dist[Location_tr[i],Location_tr[j]]<=35 && !(Location_tr[i] in Location_u && Location_tr[j] in Location_u))
	      push!(trline,Tuple([Location_tr[i],Location_tr[j]]))
			n_bun[Tuple([Location_tr[i],Location_tr[j]])] = 1
	       n_bun[Tuple([Location_tr[j],Location_tr[i]])] = 1
	       		

	       	
	    end
	  end
	end

	
	Param = gendata(n_bun,trline,Location,dist)
	Param['P'] = P_og
	plan_max = Dict()

	for i in Location
		plan_max[(i)] =100
	end 
	n_lij = 1
	m = modgen0(n_loc_og,Location_u,Location,Location_tr,trline,Param,1,p_val,plan_max)
	set_optimizer_attribute(m,"PreDual",2)
	#set_optimizer_attribute(m,"LogFile",joinpath(root,"./"*string(case)*file))
	set_optimizer_attribute(m,"Method",2)
	set_optimizer_attribute(m,"PreSolve",2)
	set_optimizer_attribute(m, "Threads", 8)
	#set_optimizer_attribute(m,"Crossover",0)
	#set_optimizer_attribute(m, "MIPGap", 0.015)
	set_optimizer_attribute(m,"TimeLimit",450)
	set_optimizer_attribute(m, "MIPGap", 0.02)
	optimize!(m)
	if (termination_status(m)==MOI.INFEASIBLE || result_count(m)==0)
		high_level_des["obj"] = 10^10
		return high_level_des
	end
	high_level_des['x'] = value.(m[:x])
	high_level_des["nt"] = value.(m[:nt])
	high_level_des["obj"] = objective_value(m)
	return high_level_des
end
