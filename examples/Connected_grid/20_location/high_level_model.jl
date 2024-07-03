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


cd(root)
include(joinpath(root,"data","Preprocess_input.jl"))

#include(joinpath(root,"Preprocess_input.jl"))
using Serialization
#FileIO.save("P1.jld2","P1",P)
include(joinpath(root,"data","calc_dist.jl"))
include(joinpath(root,"data","datagen.jl"))
include(joinpath(root,"model_mod.jl"))
include(joinpath(root,"rl_agg_og.jl"))

function gen_highlevel(p_val)
	df_loc = DataFrame(CSV.File(df_loc_path))
	n_loc_og = 20
	n_loc = n_loc_og
	trline = []
	Location = []
	Location_tr = []
	n_bun = Dict()
	n_u = 1
	for i = 1:n_loc_og
		push!(Location_tr,"r"*string(i))
	  	push!(Location,"r"*string(i))
	end
	push!(Location_tr,"ru")
	dist = cal_dist(df_loc)
	for i = 1:n_loc+n_u
	  for j = 1:n_loc+n_u
	    if (i != j)
	      push!(trline,Tuple([Location_tr[i],Location_tr[j]]))
			n_bun[Tuple([Location_tr[i],Location_tr[j]])] = 1
	       n_bun[Tuple([Location_tr[j],Location_tr[i]])] = 1
	       		

	       	
	    end
	  end
	end

	
	Param = gendata(n_bun,trline,Location,dist)
	Param['P'] = P_og

	m = modgen0(n_loc_og,Location,Location_tr,trline,Param,1,p_val)
	set_optimizer_attribute(m,"PreDual",2)
	set_optimizer_attribute(m,"Method",2)
	set_optimizer_attribute(m,"PreSolve",2)
	set_optimizer_attribute(m, "Threads", 8)
	#set_optimizer_attribute(m,"Crossover",0)
	#set_optimizer_attribute(m, "MIPGap", 0.015)
	set_optimizer_attribute(m,"TimeLimit",300)
	set_optimizer_attribute(m, "MIPGap", 0.0)
	optimize!(m)
	high_level_des=Dict()
	high_level_des['x'] = value.(m[:x])
	high_level_des["nt"] = value.(m[:nt])
	
	return high_level_des
end
