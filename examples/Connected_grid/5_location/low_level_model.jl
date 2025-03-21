function gen_lowlevel(high_level_des)
		
	if(high_level_des["obj"]==10^10)
		return 10^10
	end
	if(sum(high_level_des['x'])==0)
		return high_level_des["obj"]
	end
	df_loc = DataFrame(CSV.File(df_loc_path))
	n_loc_og = 5
	n_loc = n_loc_og
	trline = []
	Location = []
	Location_tr = []
	Location_u = []
	n_u = 1
	n_bun = Dict()
	for i = 1:n_loc_og
		push!(Location_tr,"r"*string(i))
	  	push!(Location,"r"*string(i))
	end
	push!(Location_tr,"ru")
	dist = cal_dist(df_loc)
	tline = []
	nt_num = Dict()
	plan_max = Dict()
	x0 = high_level_des['x']
	nt0 = high_level_des["nt"]
    x0 = Int.(round.(x0))
    for i = 1:n_loc+n_u
	  for j = 1:n_loc+n_u
	    if (i != j)
	      push!(trline,Tuple([Location_tr[i],Location_tr[j]]))
	    end
	  end
	end

	for (i,j) in trline
			if(nt0[(i,j)]>=1)
				push!(tline,Tuple([i,j]))
				nt_num[(i,j)] = trunc(Int,nt0[(i,j),1]) 
	            nt_num[(j,i)] = trunc(Int,nt0[(i,j),1]) 
			n_bun[(i,j)] = nt_num[(i,j)]
	       		n_bun[(j,i)] = nt_num[(i,j)]
	       		
			end
		end
	dist = cal_dist(df_loc)
	Param = gendata(n_bun,tline,Location,dist)
	Param['P'] = P_og
	plan_max = Dict()

	for i in Location
		plan_max[(i)] =100
	end 
	n_lij = 1

	println(n_bun)
	println(nt0)
	m = modgen(n_loc_og,Location,Location_tr,tline,Param,plan_max,n_lij,maximum(values(n_bun)))
	set_optimizer_attribute(m,"PreDual",2)
	#set_optimizer_attribute(m,"LogFile",joinpath(root,"./"*string(case)*file))
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
	
	for i in Location
		@constraint(m,x[:,i].==x0[:,i])
	end
	for (i,j) in tline
		c1 = ones(n_lij)
		@constraint(m,nt[(i,j),:].==c1)
	end
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
	optimize!(m)
	println(value.(m[:x]))
	a = objective_value(m)
m = Nothing
	return a
end
