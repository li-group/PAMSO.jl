using CSV
using DataFrames


function AssignP(P3,P,Location_tr)
#P = Dict()
t_s = 1:24
b1 = 1
n_loc = length(Location_tr)-1
for t = 1:n_tm
  for k= 1:n_k
  #for k = 1:d_m[t]
    for h = 1:n_s

      #Ce[(t,k,h)] = cen[h,k]*ns1[2,1]+ns1[1,1]
      for q in 1:n_loc
        P[(component[2],Location_tr[q],t,k,h)] = P3[b1]
        if (P[(component[2],Location_tr[q],t,k,h)]<=1)
          P[(component[2],Location_tr[q],t,k,h)] = 0
        end
        P[(component[3],Location_tr[q],t,k,h)] = P3[b1+1440]
        if (P[(component[3],Location_tr[q],t,k,h)]<=1)
          P[(component[3],Location_tr[q],t,k,h)] = 0
        end
      end
			b1 = b1+1
    end
  end
end
return P
end
function gendata(n_bun,trline,Location,dist)
	n_l = length(trline)
	B = Dict()

	s = Dict()
	r = Dict()
	Fl_max = Dict()
	pretran = Dict()
	Res = Dict()
	Ind = Dict()

	C_min = Dict()
	C_max = Dict()
	α = Dict()

	C_c = Dict()
	C_t = Dict()
	S = Dict()
	OCC = Dict()
	FOC = Dict()
	DIC = Dict()
	tl = Dict()
    Base_chem = Dict()
	OCC_l = Dict()
	tl_l = Dict()
	FOC_l = Dict()
	# Plant
	
	F_comp = Dict()
    θ_min = Dict()
    f_lin = Dict()
	for j in 1:n_ip
		ic = plant[j]
		df_data = DataFrame(CSV.File(files_plant[j]))
		df_data = dropmissing(df_data, :Data)
		param = df_data[:,1]
		#print(df_data)
		#println(param)
		for i in 1:nrow(df_data)
			println(param[i])
			param[i] = rstrip(param[i],' ')
		end
        for i in 1:nrow(df_data)
        	if(param[i]=="Base")
        		print(df_data[i,2])
        		Base_chem[ic] = df_data[i,2]
        	end
        	if(param[i]=="Chemical Cost")
        		C_c[df_data[i,2]] = df_data[i,4]*907
        	end
        	if(param[i]=="Transportation")
        		C_t[df_data[i,2]] = df_data[i,4]*0.621
        	end
        	if(param[i]=="alpha")
        		α[ic,df_data[i,2],df_data[i,3]] = df_data[i,4]
        	end
        	if(param[i]=="S")
        		S[(ic,df_data[i,2])] = df_data[i,4]
        	end
        	if(param[i]=="FOC")
        		FOC[ic] = df_data[i,4]
        	end
        	if(param[i]=="OCC")
        		OCC[ic] = df_data[i,4]
        	end
        	if(param[i]=="tl")
        		tl[ic] = df_data[i,4]
        	end
        	if(param[i]=="C_min")
        		C_min[ic,df_data[i,2],df_data[i,3]] = df_data[i,4]
        	end
        	if(param[i]=="C_max")
        		C_max[ic,df_data[i,2],df_data[i,3]] = df_data[i,4]
        	end
        	if(param[i]=="F")
        		F_comp[ic,df_data[i,2]] = df_data[i,4]
        	end
        	if(param[i]=="theta")
        		θ_min[ic,df_data[i,2],df_data[i,3]] = trunc(Int64,df_data[i,4])
        	end
        	if(param[i]=="f_lin")
        		f_lin[ic,df_data[i,3]] = df_data[i,4]
        	end
        end
    end
	n_l = length(trline)
	B = Dict()
    g = Dict()
	s = Dict()
	r = Dict()
	#Transmission
	S_base = 0
	
	for i in files_l
		df_data = DataFrame(CSV.File(i))
		param = df_data[:,1]
		for (i,j) in trline
		    Res[(i,j)] = ((df_data[findall( x -> x == "Res", param ),3])[1])*dist[(i,j)]*1000*(1/n_bun[(i,j)]) #per unit
		    Ind[(i,j)] = ((df_data[findall( x -> x == "Ind", param ),3])[1])*dist[(i,j)]*1000*(1/n_bun[(i,j)]) #per unit
		    B[(i,j)] = -Ind[(i,j)]/(Ind[(i,j)]^2+Res[(i,j)]^2) #per unit
		    s[(i,j)] = i
		    r[(i,j)] = j
		    g[(i,j)] = Res[(i,j)]/(Res[(i,j)]^2+Ind[(i,j)]^2)
	  	    Fl_max[(i,j)] = n_bun[(i,j)]*(df_data[findall( x -> x == "Fl_max", param ),3])[1]
		    OCC_l[(i,j)] = ((df_data[findall( x -> x == "OCC", param ),3])[1])*dist[(i,j)]*1000
		    FOC_l[(i,j)] =  n_bun[(i,j)]*((df_data[findall( x -> x == "FOC", param ),3])[1])*dist[(i,j)]*1000
		    tl_l[(i,j)] = ((df_data[findall( x -> x == "tl", param ),3])[1])

	  end
	  S_base = ((df_data[findall( x -> x == "S_base", param ),3])[1])
	end
	#println(S_base)
	for i in files_power
		df_data = DataFrame(CSV.File(i))
		param = df_data[:,1]
		for i =1:nrow(df_data)
		    if(param[i]=="FOC")
        		FOC[df_data[i,2]] = df_data[i,3]
        	end
        	if(param[i]=="OCC")
        		OCC[df_data[i,2]] = df_data[i,3]
        	end
        	if(param[i]=="tl")
        		tl[df_data[i,2]] = df_data[i,3]
        	end
		end

	end
	

	#print(θ_min)
	for i = 1:n_i
	  #If = 0
	  #If = If + 1/(1+ir)^1
	  If = 1
	  DIC[(component[i])] = OCC[(component[i])]*ir*If/(1-1/(1+ir)^tl[(component[i])])
	end
	DIC_l = Dict()
    
	for (p,v) in trline
	  #If = 0
	  #If = If + 1/(1+ir)^1
	  If = 1
	  DIC_l[(p,v)] = n_bun[(p,v)]*OCC_l[(p,v)]*ir*If/(1-1/(1+ir)^tl_l[(p,v)])
	end
	ΔC = Dict()
	#println(C_max)
	#println(C_min)
	for i in plant
	  		for mod in modes
	    		ΔC[(i,Base_chem[i],mod)]=(C_max[(i,Base_chem[i],mod)]-C_min[(i,Base_chem[i],mod)])/2
	  		end
	end
	#println(DIC)
	DIC[("Solar panel")] = DIC[("Solar panel")]/sp_prfac
	DIC[("Wind Turbine")] = DIC[("Wind Turbine")]/wt_prfac
	OCC[("Solar panel")] = OCC[("Solar panel")]/sp_prfac
	OCC[("Wind Turbine")] = OCC[("Wind Turbine")]/wt_prfac
	FOC[("Solar panel")] = FOC[("Solar panel")]/sp_prfac
	FOC[("Wind Turbine")] = FOC[("Wind Turbine")]/wt_prfac
    h = Base.@locals
	Param = Dict()
	
    for i in keys(h)
        Param[String(i)] = h[i]
    end
    cd(root)
   return Param
end