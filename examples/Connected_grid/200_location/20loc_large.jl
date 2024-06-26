case = 6
file = "MADS/_20_loc_base_large_finnew.txt"
file1 = "MADS/_20_loc_res_base_large_finnew.txt"
file2 = "MADS/_20_loc_act_base_large_finnew.txt"
file3 = "MADS/_20_loc_sens_base_large_finnew.txt"

using Dates
using DataFrames
using CSV
using Statistics
using Clustering
using FileIO
using JuMP
import Gurobi
using Optim
import XLSX
 import Distributions: Uniform
 using Serialization
root = pwd()
Example_folder = "Example_4"
cd("../")
rootn = pwd()
cd(root)
include(joinpath(rootn,"Examples",Example_folder,"Preprocess_input3.jl"))
#include(joinpath(root,"Preprocess_input.jl"))
using Serialization
#FileIO.save("P1.jld2","P1",P)
include(joinpath(root,"calc_dist.jl"))
include(joinpath(root,"datagen_1.jl"))
include(joinpath(root,"model_mod_multi.jl"))
include(joinpath(root,"rl_agg_og_multi.jl"))

outp = DataFrame(A = "Time",B = "Objective Value",C = "Objective Bound",D = "Termination Status of 5 rep day model",E = "Solar",F = "Power",G = Dates.format(now(), "e: dd u yy, HH.MM.SS"))
CSV.write(joinpath(root,"./"*string(case)*"MADS/large20loc.csv"),outp,append = true)

function rlimp(p_val)

    par_val = Dict()
    #for i in 1:length(powergen)
    par_val[("Solar panel")] = p_val[1]
    par_val[("Wind Turbine")] = 1
    #end
    for i in plant
    	par_val[(i)] = 1
    end 
    per_val = p_val[2]
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

	m = modgen0(n_loc_og,Location_u,Location,Location_tr,trline,Param,1,par_val,per_val)

	set_optimizer_attribute(m,"PreDual",2)
	set_optimizer_attribute(m,"LogFile",joinpath(root,"./"*string(case)*file))
	set_optimizer_attribute(m,"Method",2)
	set_optimizer_attribute(m,"PreSolve",2)
	set_optimizer_attribute(m, "Threads", 8)
	#set_optimizer_attribute(m,"Crossover",0)
	#set_optimizer_attribute(m, "MIPGap", 0.015)
	set_optimizer_attribute(m,"TimeLimit",450)
	set_optimizer_attribute(m, "MIPGap", 0.02)
    Loc_no = []
    x = m[:x]
    nt = m[:nt]
     
	optimize!(m)
	t1 = solve_time(m)
	if(termination_status(m)==MOI.INFEASIBLE)
		return 10^10
	end
    open(joinpath(root,"./"*string(case)*file1),"a") do io
		println(io,objective_value(m))
		println(io,par_val)
		println(io,per_val)
	end

	open(joinpath(root,"./"*string(case)*file3),"a") do io
		println(io,objective_value(m))
	end

	x0 = value.(m[:x])
	nt0 = value.(m[:nt])
	#Q0 = value.(m[:Q_1])
	#Tr0 = value.(m[:Tr_1])
	#FileIO.save("x_0.jld2","x",x0)
	#FileIO.save("nt_0.jld2","nt",nt0)
	tline = []
	nt_num = Dict()
	plan_max = Dict()
    x0 = Int.(round.(x0))
    Loc_n = []
    Loc_ntr = []
	open(joinpath(root,"./"*string(case)*file),"a") do io
		println(io,x0)
		for (i,j) in trline
			if(nt0[(i,j),1]>=1)
				println(io,nt0[(i,j),1])
				println(io,(i,j))
				push!(tline,Tuple([i,j]))
				nt_num[(i,j)] = trunc(Int,nt0[(i,j),1]) 
				#nt_num[(i,j)] = 1
				#push!(tline,Tuple([j,i]))
	            nt_num[(j,i)] = trunc(Int,nt0[(i,j),1]) 
				#nt_num[(j,i)] =nt_num[(i,j)] 
				n_bun[(i,j)] = nt_num[(i,j)]
	       		n_bun[(j,i)] = nt_num[(i,j)]
	       	if (!(i in Loc_n) && i in Location)
				push!(Loc_n,i)
				push!(Loc_ntr,i)
			end
			if (!(j in Loc_n) && j in Location )
				push!(Loc_n,j)
				push!(Loc_ntr,j)
			end
			end
			
		end
	end
	print(Loc_n)

	dist = cal_dist(df_loc)
	Param = gendata(n_bun,tline,Location,dist)
	Param['P'] = P_og
	plan_max = Dict()

	for i in Location
		plan_max[(i)] =100
	end 
	n_lij = 1

	#n_lij = maximum(values(nt_num))
	
	for i in Location
		if(sum(x0[:,i])>=1 && !(i  in Loc_n))
			push!(Loc_n,i)
			push!(Loc_ntr,i)
		end
	end

	for i = 1:n_u
		push!(Loc_ntr,"ru"*string(i))
	end
	println(Loc_n)
	if(length(Loc_n)==0)
		outp = DataFrame(A = t1,B = objective_value(m),C = objective_bound(m),D = termination_status(m),E = p_val[1],F = p_val[2],G = Dates.format(now(), "e: dd u yy, HH.MM.SS"))
		CSV.write(joinpath(root,"./"*string(case)*"MADS/large20loc.csv"),outp,append = true)

		return objective_value(m)
	end
	m = modgen(n_loc_og,Location_u,Loc_n,Loc_ntr,tline,Param,plan_max,n_lij,maximum(values(n_bun)))
	set_optimizer_attribute(m,"PreDual",2)
	set_optimizer_attribute(m,"LogFile",joinpath(root,"./"*string(case)*file))
	set_optimizer_attribute(m,"Method",2)
	set_optimizer_attribute(m,"DegenMoves",0)
	set_optimizer_attribute(m,"NonConvex",2)
	set_optimizer_attribute(m, "Threads", 8)
	set_optimizer_attribute(m, "MIPGap", 0.005)
	set_optimizer_attribute(m,"TimeLimit",1500)
	y_1 = m[:y_1]
	z_1 = m[:z_1]
	x = m[:x]
	nt = m[:nt]
	#println(x)
	for i in Loc_n
		@constraint(m,x[:,i].==x0[:,i])
	end
	for (i,j) in tline
		c1 = ones(n_lij)
		for k in 1:nt_num[(i,j)]
	    #for k in 1:n_lij
	    #if(nt_num[(i,j)]==1)
			#c1[k] = 1
		end
		@constraint(m,nt[(i,j),:].==c1)
	end
	for i in plant
	for loc in Loc_n
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
#=
@constraint(m,sum(x["Wind Turbine",Location])==2)
@constraint(m,sum(x["Plant",Location])==0)
@constraint(m,sum(x["Solar panel",Location])==2)
@constraint(m,x["Solar panel","r2"]==2)
@constraint(m,x["Wind Turbine","r2"]==2)=#

#undo = relax_integrality(m)

#@constraint(m,Q_1.==Q0)
#@constraint(m,Tr_1.==Tr0)

optimize!(m)
open(joinpath(root,"result_file_new.txt"),"a") do io
	println(io,p_val)
    println(io,solution_summary(m))

    println(io,"Total material cost =")
    println(io,sum(value.(matcostc)))
    println(io,"only material cost =")
    #println(io,sum(value.(matcostnormc)))

    println(io,"Transportation cost =")
    println(io,sum(value.(transcostc)))

    println(io,"Electricity cost =")
    println(io,sum(value.(eleccost)))

    println(io,"FIXOP cost =")
    println(io,sum(value.(FIXOP)))

    println(io,"FIXOP_l cost =")
    println(io,sum(value.(FIXOP_l)))

    println(io,"CAPEX cost =")
    println(io,sum(value.(CAPEX)))

    println(io,"CAPEX_l =")
    println(io,sum(value.(CAPEX_l)))
end

x1 = value.(x)
open(joinpath(root,"./"*string(case)*file),"a") do io
		println(io,x1)
		println(io,tline)
	end
if(termination_status(m)==MOI.INFEASIBLE)
		return 10^10
	end
if(result_count(m)==0)
        return objective_bound(m)

else
open(joinpath(root,"./"*string(case)*file1),"a") do io
	println(io,objective_value(m))
	println(io,objective_bound(m))
end
end
t2 = solve_time(m)
outp = DataFrame(A = t1+t2,B = objective_value(m),C = objective_bound(m),D = termination_status(m),E = p_val[1],F = p_val[2],G = Dates.format(now(), "e: dd u yy, HH.MM.SS"))
CSV.write(joinpath(root,"./"*string(case)*"MADS/large20loc.csv"),outp,append = true)

a = objective_value(m)
m = Nothing
	return a
end
#rlimp([0.314891,0.056021])
#rlimp([1,0])
#rlimp([1,1])
#rlimp([0.8002,0.0799616])
#=
using NOMAD
function bb(x)
  f =  rlimp(x)
 # c = 1 - x[1]
  success = true
  count_eval = true
  bb_outputs = [f]
  return (success, count_eval, bb_outputs)
end
p = NomadProblem(2, 1, ["OBJ"], bb,
                lower_bound=[0.0,0.0],
                upper_bound=[1.0,1.0],initial_mesh_size = [0.5,0.5])
p.options.display_degree = 2
p.options.sgtelib_model_max_eval = 600
p.options.max_bb_eval = 600
#p.options.SGTELIB_MODEL_DIVERSIFICATION = 0.5
#p.options.anisotropy_factor = 0.5
p.options.display_stats = ["BBE","BBO","ITER_NUM","OBJ","SOL","TIME","TOTAL_SGTE"]
result = solve(p, [1.0,1.0])
=#
#rlimp([1,1])

#rlimp([0.304891,0.066021])
#rlimp([0.1,0.0715])
rlimp([0.84043103969857,0.06968479796583])
#=
outp = DataFrame(A = "Transfer-5loc",B = "Objective Value",C = "Objective Bound",D = "Termination Status of 5 rep day model",E = "Solar",F = "Power",G = Dates.format(now(), "e: dd u yy, HH.MM.SS"))
CSV.write(joinpath(root,"./"*string(case)*"MADS/large20loc.csv"),outp,append = true)
x0_5loc = [0.294891,0.056021]
using NOMAD
function bb(x)
  f =  rlimp(x)
 # c = 1 - x[1]
  success = true
  count_eval = true
  bb_outputs = [f]
  return (success, count_eval, bb_outputs)
end
p = NomadProblem(2, 1, ["OBJ"], bb,
                lower_bound=max.(x0_5loc.-0.05,0),
                upper_bound=min.(x0_5loc.+0.05,1))
p.options.display_degree = 2
p.options.sgtelib_model_max_eval = 20
p.options.max_bb_eval = 20
#p.options.SGTELIB_MODEL_DIVERSIFICATION = 0.5
#p.options.anisotropy_factor = 0.5
p.options.display_stats = ["BBE","BBO","ITER_NUM","OBJ","SOL","TIME","TOTAL_SGTE"]
result = solve(p, x0_5loc)

outp = DataFrame(A = "Transfer-20loc",B = "Objective Value",C = "Objective Bound",D = "Termination Status of 5 rep day model",E = "Solar",F = "Power",G = Dates.format(now(), "e: dd u yy, HH.MM.SS"))
CSV.write(joinpath(root,"./"*string(case)*"MADS/large20loc.csv"),outp,append = true)
x0_20loc = [0.1,0.0715]
using NOMAD
function bb(x)
  f =  rlimp(x)
 # c = 1 - x[1]
  success = true
  count_eval = true
  bb_outputs = [f]
  return (success, count_eval, bb_outputs)
end
p = NomadProblem(2, 1, ["OBJ"], bb,
                lower_bound=max.(x0_20loc.-0.05,0),
                upper_bound=min.(x0_20loc.+0.05,1))
p.options.display_degree = 2
p.options.sgtelib_model_max_eval = 20
p.options.max_bb_eval = 20
#p.options.SGTELIB_MODEL_DIVERSIFICATION = 0.5
#p.options.anisotropy_factor = 0.5
p.options.display_stats = ["BBE","BBO","ITER_NUM","OBJ","SOL","TIME","TOTAL_SGTE"]
result = solve(p, x0_20loc)
