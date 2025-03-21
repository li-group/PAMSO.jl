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

df_loc = DataFrame(CSV.File(df_loc_path))
	n_loc_og = 20
	n_loc = n_loc_og
	trline = []
	Location = []
	Location_tr = []
	n_bun = Dict()
	for i = 1:n_loc_og
		push!(Location_tr,"r"*string(i))
	  	push!(Location,"r"*string(i))
	end
	push!(Location_tr,"ru")
	for i = 1:n_loc+1
	  for j = 1:n_loc+1
	    if (i != j )
	      push!(trline,Tuple([Location_tr[i],Location_tr[j]]))
			n_bun[Tuple([Location_tr[i],Location_tr[j]])] = 20
	       n_bun[Tuple([Location_tr[j],Location_tr[i]])] = 20
	    end
	  end
	end
	dist = cal_dist(df_loc)
	Param = gendata(n_bun,trline,Location,dist)
	Param['P'] = P_og
	plan_max = Dict()

	for i in Location
		plan_max[(i)] =100
	end 
	n_lij = 1

	#n_lij = maximum(values(nt_num))

	m = modgen(n_loc_og,Location,Location_tr,trline,Param,plan_max,n_lij,maximum(values(n_bun)))
	set_optimizer_attribute(m,"PreDual",2)
	set_optimizer_attribute(m,"Method",2)
	set_optimizer_attribute(m,"DegenMoves",0)
	#set_optimizer_attribute(m,"NonConvex",2)
	set_optimizer_attribute(m, "Threads", 8)
	set_optimizer_attribute(m,"Crossover",0)
	#set_optimizer_attribute(m, "MIPGap", 0.005)
	#set_optimizer_attribute(m,"TimeLimit",1500)
	#undo = relax_integrality(m)
y_1 = m[:y_1]
	z_1 = m[:z_1]
for i in plant
	for loc in Location
		for mo in modes
			for t= 1:n_tm
				for k = 1:n_k
					for h = 1:n_s
						set_integer(y_1[i,loc,mo,t,k,h])
						for mo1 in modes
							set_integer(z_1[i,loc,mo,mo1,t,k,h])
						end
					end
				end
			end
		end
	end
	end

fs_model = m
