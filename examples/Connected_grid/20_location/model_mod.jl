
macro string_as_varname_macro(s::AbstractString, v::Any)
	s = Symbol(s)
	esc(:($s = $v))
end
function extract(d)
    expr = quote end
    for (k, v) in d
        push!(expr.args, :($(Symbol(k)) = $v))
    end
    eval(expr)
    return
end
function modgen(n_loc,Location,Location_tr,trline,Param,plan_max,n_lij,n_bun_agg)
	extract(Param)
	function variable_init() #Function to initialize model and variables
	    m = Model(Gurobi.Optimizer)
	    set_optimizer_attribute(m, "DualReductions", 0)
	    @variable(m,x[i in component,loc in Location],Int)
	    @variable(m,nt[(i,j) in trline,1:n_lij],Bin)
		@variable(m,0<=y_1[i in plant,loc in Location,mod1 in modes,1:n_tm,1:n_k,1:n_s])
	    @variable(m,0<=z_1[i in plant,loc in Location,mod1 in modes,mod2 in modes,1:n_tm,1:n_k,1:n_s])
	    @variable(m,F_1[i in plant,c in chemical,loc in Location,1:n_tm,1:n_k,1:n_s])
	    @variable(m,F_1_mod[i in plant,c in chemical,loc in Location,mod1 in modes,1:n_tm,1:n_k,1:n_s])
	    @variable(m,0<=Q_1[i in plant,c in chemical,loc in Location,1:n_tm])
	    @variable(m,Tr_1[i in plant,c in chemical,loc in Location,j in Consumer_supplier,1:n_tm])
	    @variable(m,0<=sltr_1[c in chemical,j in Consumer_supplier,1:n_tm])
	    @variable(m,Po_1[i in plant,loc in Location_tr,1:n_tm,1:n_k,1:n_s])
	    @variable(m,p_flow[(i,j) in trline,1:n_lij,1:n_tm,1:n_k,1:n_s])
	    @variable(m,p_flowext[1:n_tm,1:n_k,1:n_s])
	    @variable(m,V_flow[loc in Location_tr,1:n_tm,1:n_k,1:n_s])
	    @variable(m,p_cu[loc in Location_tr,1:n_tm,1:n_k,1:n_s]>=0)
	    return m

	end
	m = variable_init()
	println("yes")
	#yc = counts(X_kmoid)

	function xmax(m) #Function to add constraints on x
	    x = m[:x]
	    nt = m[:nt]
	    
	    @constraint(m,xm[loc in Location],sum(x["Plant",loc]).<=plan_max[(loc)]) #plan_max = Maximum number of plants in a location
	    @constraint(m,xm2[loc in Location],sum(x["Wind Turbine",loc]).<=max_wt_pl*plan_max[(loc)])
	    @constraint(m,xm3[loc in Location],sum(x["Solar panel",loc]).<=max_sp_pl*plan_max[(loc)])
	   	@constraint(m,sum(x["Wind Turbine",Location])<=max_wt)
	    @constraint(m,sum(x["Solar panel",Location])<=max_sp)
	    @constraint(m,xm1[i in component,loc in Location],x[i,loc]>=0)
	    @constraint(m,trx[loc in Location],(sum(nt[(p,v),l] for l in 1:n_lij for (p,v) in trline if v==loc)+sum(nt[(p,v),l] for l in 1:n_lij for (p,v) in trline if p==loc))*5000*plan_max[(loc)]>=sum(x[:,loc]))
	    #@constraint(m,trx1[loc in Location],(sum(nt[(p,v),l] for l in 1:n_lij for (p,v) in trline if v==loc)+sum(nt[(p,v),l] for l in 1:n_lij for (p,v) in trline if p==loc))*5*plan_max[(loc)]>=sum(x[:,loc]))
	    
	    return m
	end

	m = xmax(m)
	println("yes")
	function transpconss(m) #Function to add constraints on transportation
	    Tr_1 = m[:Tr_1]
	    sltr_1 = m[:sltr_1]
	 
	    if length(Consumer_suppliercom)>=1
	        @constraint(m,logcon[i in plant,j in Consumer_suppliercom,loc in Location,t in 1:n_tm],Tr_1[i,chemical[(!in).(chemical,Ref(vcat(c_jp[(j,)],c_jr[(j,)])))],loc,j,t] .== 0)
	    end
	    if length(Consumer_only)>=1
	        @constraint(m,logcon3[i in plant,j in Consumer_only,loc in Location,t in 1:n_tm],Tr_1[i,chemical[(!in).(chemical,Ref(c_jp[(j,)]))],loc,j,t] .== 0)
	    end
	    if length(Supplier_only)>=1
	        @constraint(m,logcon4[i in plant,j in Supplier_only,loc in Location,t in 1:n_tm],Tr_1[i,chemical[(!in).(chemical,Ref(c_jr[(j,)]))],loc,j,t] .== 0)
	    end
	    @constraint(m,logcon1[j in Consumer,t in 1:n_tm],sltr_1[chemical[(!in).(chemical,Ref(c_jp[(j,)]))],j,t] .== 0)
	    @constraint(m,logconpro[i in plant,j in Consumer,loc in Location,t in 1:n_tm,c in c_jp[(j,)]],Tr_1[i,c,loc,j,t].*S[(i,c)] .>= 0)
	    @constraint(m,logconraw[i in plant,j in Supplier,loc in Location,t in 1:n_tm,c in c_jr[(j,)]],Tr_1[i,c,loc,j,t].*S[(i,c)] .>= 0)
	    for c in chemical
	       for i in plant
		       if(S[i,c]==0)	
		    		@constraint(m,logconpro1[j in Consumer,loc in Location,t in 1:n_tm],Tr_1[i,c,loc,j,t] == 0)
		    		@constraint(m,logconraw1[j in Supplier,loc in Location,t in 1:n_tm],Tr_1[i,c,loc,j,t] == 0)
		       end
		    end
		end

	    return m
	end
	m = transpconss(m)
	println("yes")
	function chemplant(m) #Function to add constraints relating to chemical plant
	    x = m[:x]
	    y= m[:y_1]
	    z = m[:z_1]
	    F_1_mod = m[:F_1_mod]
	    F_1 = m[:F_1]
	    Q_1 = m[:Q_1]
	    Tr_1 = m[:Tr_1]
	    sltr_1 = m[:sltr_1]
	    Po_1 = m[:Po_1]
	    M1 = 100
	    coc = 0.1
	    @constraint(m,zcon[i in plant,loc in Location,t=1:n_tm,k=1:n_k,h=1:n_s,mod1 in modes],z[i,loc,mod1,mod1,t,k,h]==0)
	    @constraint(m,zcon1[i in plant,loc in Location,t=1:n_tm,k=1:n_k,h=1:n_s,mod1 in modes],z[i,loc,mod1,mod1,t,k,h]<=x[i,loc])
	    @constraint(m,modesxy[i in plant,loc in Location,t=1:n_tm,k=1:n_k,h=1:n_s],sum(y[i,loc,modes,t,k,h])==x[i,loc])
	    @constraint(m,zcon2[i in plant,loc in Location,t=1:n_tm,k=1:n_k,h=1:n_s],sum(z[i,loc,modes,modes,t,k,h])<=x[i,loc])
	    @constraint(m,modesyz[i in plant,loc in Location,t=1:n_tm,k=1:n_k,h=2:n_s,mod1 in modes],sum(z[i,loc,modes,mod1,t,k,h-1])-sum(z[i,loc,mod1,modes,t,k,h-1])==y[i,loc,mod1,t,k,h]-y[i,loc,mod1,t,k,h-1])
	    @constraint(m,modestryz[i in plant,loc in Location,t=1:n_tm,k=1:n_k,h=2:n_s,mod1 in modes,mod2 in modes],sum(z[i,loc,mod2,mod1,t,k,h-h1] for h1 in 1:θ_min[i,mod2,mod1] if h1<=h-1)<=y[i,loc,mod1,t,k,h])
	    @constraint(m,stoic[i in plant,mod1 in modes,c in chemical,c1 in chemical,loc in Location,t=1:n_tm,k=1:n_k,h=1:n_s],1000*F_1_mod[i,c,loc,mod1,t,k,h].*α[i,c1,mod1]./mw[(c,)].==1000*F_1_mod[i,c1,loc,mod1,t,k,h].*α[i,c,mod1]./mw[(c1,)])
	    @constraint(m,stoichadd[i in plant,c in chemical,loc in Location,t=1:n_tm,k=1:n_k,h=1:n_s],F_1[i,c,loc,t,k,h].==sum(F_1_mod[i,c,loc,modes,t,k,h]))
	    @constraint(m,minp[i in plant,mod1 in modes,loc in Location,t=1:n_tm,k=1:n_k,h=1:n_s],F_1_mod[i,Base_chem[i],loc,mod1,t,k,h]>=y[i,loc,mod1,t,k,h].*C_min[(i,Base_chem[i],mod1)])
	    @constraint(m,maxp[i in plant,mod1 in modes,loc in Location,t=1:n_tm,k=1:n_k,h=1:n_s],F_1_mod[i,Base_chem[i],loc,mod1,t,k,h]<=y[i,loc,mod1,t,k,h].*C_max[(i,Base_chem[i],mod1)])
	    @constraint(m,ramp1[i in plant,mod1 in modes,loc in Location,t=1:n_tm,k=1:n_k,h=1:n_s-1],F_1_mod[i,Base_chem[i],loc,mod1,t,k,h+1]<=F_1_mod[i,Base_chem[i],loc,mod1,t,k,h]+ΔC[(i,Base_chem[i],mod1)]*y[i,loc,mod1,t,k,h]+M1*(2*x[i,loc]-y[i,loc,mod1,t,k,h]-y[i,loc,mod1,t,k,h+1]))
	    @constraint(m,ramp2[i in plant,mod1 in modes,loc in Location,t=1:n_tm,k=1:n_k,h=1:n_s-1],F_1_mod[i,Base_chem[i],loc,mod1,t,k,h+1]>=F_1_mod[i,Base_chem[i],loc,mod1,t,k,h]-ΔC[(i,Base_chem[i],mod1)]*y[i,loc,mod1,t,k,h]-M1*(2*x[i,loc]-y[i,loc,mod1,t,k,h]-y[i,loc,mod1,t,k,h+1]))
	    @constraint(m,inven1[i in plant,c in chemical,loc in Location],Q_1[i,c,loc,1].==sum(w[(k,1)].*F_1[i,c,loc,1,k,h] for k in 1:n_k for h in 1:n_s)-sum(Tr_1[i,c,loc,Consumer_supplier,1]))
	    @constraint(m,inven[i in plant,c in chemical,loc in Location,t = 2:n_tm],Q_1[i,c,loc,t].==Q_1[i,c,loc,t-1]+sum(w[(k,t)]*F_1[i,c,loc,t,k,h] for k in 1:n_k for h in 1:n_s)-sum(Tr_1[i,c,loc,Consumer_supplier,t]))
	    @constraint(m,transdem[j in Consumer_supplier,c in c_jp[(j,)],t = 1:n_tm],sum(Tr_1[plant,c,Location,j,t])+sltr_1[c,j,t]==D[(c,j,t)])
	    @constraint(m,powerel[i in plant,loc in Location,t=1:n_tm,k=1:n_k,h=1:n_s],0.1*Po_1[i,loc,t,k,h].==sum(0.1*F_1_mod[i,Base_chem[i],loc,mod1,t,k,h]*f_lin[(i,mod1)] for mod1 in modes)+sum(0.1*F_1[i,c,loc,t,k,h].*F_comp[(i,c)].*S[(i,c)] for c in chemical))
	    @constraint(m,invenboun2up[i in plant,c in chemical, loc in Location,t=1:n_tm],0.1*Q_1[i,c, loc, t] .<=0.1*80000* x[i, loc])
	    for mod1 in modes 
	    	for i in plant
	       		if(C_min[(i,Base_chem[i],mod1)]==0 && C_max[(i,Base_chem[i],mod1)]==0) 
	       			for t = 1:n_tm
	       				for k = 1:n_k
	       					for h = 1:n_s
	       						for c in chemical
	       							for loc in Location
	    								@constraint(m,F_1_mod[i,c,loc,mod1,t,k,h]==0)
	    							end
	    						end
	    					end
	    				end
	    			end
	    		end
	    	end
	    end
	    return m
	end
	    
	m = chemplant(m)
	println("yes")
	function powerbal(m) #Function to add constraints on power balance
	    Po_1 = m[:Po_1]
	    p_flow= m[:p_flow]
	    p_cu= m[:p_cu]
	    p_flowext = m[:p_flowext]
	    x = m[:x]
	   
	    @variable(m,Gen[loc in Location,1:n_tm,1:n_k,1:n_s])
	    @variable(m,Dempl[loc in Location,1:n_tm,1:n_k,1:n_s])
	    @constraint(m,gcon[loc in Location,t=1:n_tm,k=1:n_k,h=1:n_s],S_base*Gen[loc,t,k,h].==(P[("Solar panel",loc,t,k,h)].*x["Solar panel",loc]+P[("Wind Turbine",loc,t,k,h)].*x["Wind Turbine",loc]))
	    @constraint(m,dcon[loc in Location,t=1:n_tm,k=1:n_k,h=1:n_s],S_base*Dempl[loc,t,k,h].==sum(Po_1[plant,loc,t,k,h]))
	    @constraint(m,curtail[loc in Location,t=1:n_tm,k=1:n_k,h=1:n_s], p_cu[loc,t,k,h] <= Gen[loc,t,k,h])
	    @constraint(m,powbaln1[loc in Location,t=1:n_tm,k=1:n_k,h=1:n_s],p_cu[loc,t,k,h] + Dempl[loc,t,k,h].==Gen[loc,t,k,h] -sum(p_flow[(p,v),l,t,k,h] for l in 1:n_lij for (p,v) in trline if p==loc)) 
	    @constraint(m,powbalru[t=1:n_tm,k=1:n_k,h=1:n_s],p_flowext[t,k,h]==sum(p_flow[(p,v),l,t,k,h] for l in 1:n_lij for (p,v) in trline if p=="ru")) 
	    return m
	end
	m = powerbal(m)
	println("yes")

	function transcon2(m) #Function to add constraints on power flow in transmision lines
	    p_flow= m[:p_flow]
	    V_flow = m[:V_flow]
	    n = m[:nt]
	    lo = 0.95
	    up = 1.05
	    M = 3000*n_bun_agg/100
	    @variable(m,lo^2<=Cpp[loc in Location_tr,1:n_tm,1:n_k,1:n_s]<=up^2)
	    @variable(m,Cpv[(p,v) in trline,1:n_tm,1:n_k,1:n_s])
	    @constraint(m,thetacon1[p in Location_tr,t=1:n_tm,k=1:n_k,h=1:n_s],V_flow[p,t,k,h]<=1.05)
	    @constraint(m,thetacon2[p in Location_tr,t=1:n_tm,k=1:n_k,h=1:n_s],V_flow[p,t,k,h]>=0.95)
	    @constraint(m,tr3[(p,v) in trline,t=1:n_tm,k=1:n_k,h=1:n_s,l=1:n_lij],-0.01*Fl_max[(p,v)]*n[(p,v),l].<=0.01*p_flow[(p,v),l,t,k,h]*S_base)
	    @constraint(m,tr4[(p,v) in trline,t=1:n_tm,k=1:n_k,h=1:n_s,l=1:n_lij],0.01*p_flow[(p,v),l,t,k,h]*S_base.<=0.01*Fl_max[(p,v)]*n[(p,v),l])
	   	#@constraint(m,tr8[(p,v) in trline,l=1:n_lij-1],n[(p,v),l]>=n[(p,v),l+1])
	    @constraint(m,tr8a[(p,v) in trline,l=1:n_lij],n[(p,v),l]==n[(v,p),l])	    
	    @constraint(m,tr11[p in Location_tr,t=1:n_tm,k=1:n_k,h=1:n_s,l=1:n_lij],Cpp[p,t,k,h]>=2*lo*V_flow[p,t,k,h]-lo^2)
	    @constraint(m,tr12[p in Location_tr,t=1:n_tm,k=1:n_k,h=1:n_s,l=1:n_lij],Cpp[p,t,k,h]>=2*up*V_flow[p,t,k,h]-up^2)
	    @constraint(m,tr13[p in Location_tr,t=1:n_tm,k=1:n_k,h=1:n_s,l=1:n_lij],Cpp[p,t,k,h]<=(lo+up)*V_flow[p,t,k,h]-lo*up)
	    @constraint(m,tr14[(p,v) in trline,t=1:n_tm,k=1:n_k,h=1:n_s,l=1:n_lij],Cpv[(p,v),t,k,h]>=lo*V_flow[p,t,k,h]+lo*V_flow[v,t,k,h]-lo^2)
	    @constraint(m,tr15[(p,v) in trline,t=1:n_tm,k=1:n_k,h=1:n_s,l=1:n_lij],Cpv[(p,v),t,k,h]>=up*V_flow[p,t,k,h]+up*V_flow[v,t,k,h]-up^2)
        @constraint(m,tr16[(p,v) in trline,t=1:n_tm,k=1:n_k,h=1:n_s,l=1:n_lij],Cpv[(p,v),t,k,h]<=lo*V_flow[p,t,k,h]+up*V_flow[v,t,k,h]-lo*up)
        @constraint(m,tr17[(p,v) in trline,t=1:n_tm,k=1:n_k,h=1:n_s,l=1:n_lij],Cpv[(p,v),t,k,h]<=up*V_flow[p,t,k,h]+lo*V_flow[v,t,k,h]-lo*up)
        @constraint(m,tr18[(p,v) in trline,t=1:n_tm,k=1:n_k,h=1:n_s,l=1:n_lij],p_flow[(p,v),l,t,k,h]+p_flow[(v,p),l,t,k,h]>=0)
        
        @constraint(m,tr19[(p,v) in trline,t=1:n_tm,k=1:n_k,h=1:n_s,l=1:n_lij],0.1*p_flow[(p,v),l,t,k,h]-0.1*g[(p,v)]*(Cpp[p,t,k,h]-Cpv[(p,v),t,k,h])>=-0.1*M*(1-n[(p,v),l]))
        @constraint(m,tr22[(p,v) in trline,t=1:n_tm,k=1:n_k,h=1:n_s,l=1:n_lij],0.1*p_flow[(p,v),l,t,k,h]-0.1*g[(p,v)]*(Cpp[p,t,k,h]-Cpv[(p,v),t,k,h])<=0.1*M*(1-n[(p,v),l]))

	    return m
	end
	m = transcon2(m)
	println("yes")
	function obj(m) #Function to objective function

	    Tr_1 = m[:Tr_1]
	    sltr_1 = m[:sltr_1]
	    x = m[:x]
	    y = m[:y_1]
	    n = m[:nt]
	    p_flowext = m[:p_flowext]
	    global matcostc = @expression(m,[i in plant,c in chemical],sum(Tr_1[i,c,:,:,:].*C_c[(c)])-sum(sltr_1[c,:,:].*C_c[(c)]*(sl_fac)))
	    #global matcostnormc = @expression(m,[c in chemical],sum(Tr_1[c,:,:,:].*C_c[(c,)]))
	    global transcostc = @expression(m,[i in plant,c in chemical,j in Consumer_supplier,loc in Location],sum(Tr_1[i,c,loc,j,:].*S[(i,c)].*C_t[(c)].*dist[(loc,j)]))
	    global eleccost = @expression(m,[t = 1:n_tm,k=1:n_k,h = 1:n_s],w[(k,t)].*Ce[(t,k,h)].*p_flowext[t,k,h]*S_base*elec_fac*1)
	    global FIXOP = @expression(m,[i in component],sum(FOC[(i)].*x[i,:])/n_m)
	    if(length(trline)==0)
	    	global FIXOP_l = 0
	    else
		    global FIXOP_l = @expression(m,[(p,v) in trline],sum(FOC_l[(p,v)].*n[(p,v),l] for l in 1:n_lij)*1/(2*n_m))
		end
	    global CAPEX = @expression(m,[i in component],sum(DIC[(i)].*x[i,:])/n_m)
	    if(length(trline)==0)
	    	global CAPEX_l = 0
	    else
		    global CAPEX_l = @expression(m,[(p,v) in trline],sum(DIC_l[(p,v)].*n[(p,v),l] for l in 1:n_lij)*1/(2*n_m))
		end

	    @objective(m,Min,-(sum(matcostc)-sum(transcostc)-sum(eleccost)-sum(FIXOP)-sum(FIXOP_l)-sum(CAPEX)-sum(CAPEX_l))/1000)
	    return m
	end
	m = obj(m)
	return m
end
