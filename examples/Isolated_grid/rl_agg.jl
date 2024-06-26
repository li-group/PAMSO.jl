
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
function modgen0(n_loc,Location,Location_tr,trline,Param,n_lij,p_val)
	Max_inv = Dict()
   	
    #for i in 1:length(powergen)
    Max_inv[("Solar panel")] = 0
    Max_inv[("Wind Turbine")] = p_val[1]
    
    #end
   
    per_val = p_val[2]
	extract(Param)
	function variable_init() #Function to initialize model and variables
	    m = Model(Gurobi.Optimizer)
	    set_optimizer_attribute(m, "DualReductions", 0)
	    @variable(m,x[i in component,loc in Location],Int)
	    @variable(m,nt[(i,j) in trline],Int)
	   #@variable(m,nt1[(i,j) in trline],Int)
	   #@constraint(m,sumnt[(p,v) in trline],sum(nt[(p,v),:]).==nt1[(p,v)])
	    @variable(m,0<=y_1[i in plant,loc in Location,mod in modes,1:n_tm])
	    @variable(m,0<=z_1[i in plant,loc in Location,mod in modes,mod1 in modes,1:n_tm])
	    @variable(m,F_1[i in plant,c in chemical,loc in Location,1:n_tm])
	    @variable(m,F_1_mod[i in plant,c in chemical,loc in Location,mod in modes,1:n_tm])
	    @variable(m,0<=Q_1[i in plant,c in chemical,loc in Location,1:n_tm])
	    @variable(m,Tr_1[i in plant,c in chemical,loc in Location,j in Consumer_supplier,1:n_tm])
	    @variable(m,0<=sltr_1[c in chemical,j in Consumer_supplier,1:n_tm])
	    @variable(m,Po_1[i in plant,loc in Location_tr,1:n_tm])
	    @variable(m,p_flow[(i,j) in trline,1:n_tm])
	    @variable(m,p_flowext[1:n_tm])
	    
	    @variable(m,p_cu[loc in Location_tr,1:n_tm]>=0)


	    return m

	end
	m = variable_init()
	println("yes")
	#yc = counts(X_kmoid)

	function xmax(m) #Function to add constraints on x
	    x = m[:x]
	    nt = m[:nt]
	    
	   #@constraint(m,xm[loc in Location],sum(x["Plant",loc]).<=1)
	   #@constraint(m,xm2[loc in Location],sum(x["Wind Turbine",loc]).<=20)
	   #@constraint(m,xm3[loc in Location],sum(x["Solar panel",loc]).<=2)
	    #@constraint(m,sum(x["Plant",Location]).<=4)
	    #@constraint(m,sum(x["Wind Turbine",Location])<=max_wt)
	    #@constraint(m,sum(x["Solar panel",Location])<=max_sp)
	    @constraint(m,sum(x["Wind Turbine",Location])>=Max_inv["Wind Turbine"])
	    @constraint(m,sum(x["Solar panel",Location])>=Max_inv["Solar panel"])
	    @constraint(m,sum(x["Wind Turbine",Location])<=max_wt)
	    @constraint(m,sum(x["Solar panel",Location])<=max_sp)
	    @constraint(m,xm1[i in component,loc in Location],x[i,loc]>=0)
	    
	    #@constraint(m,xm3[loc in Location],sum(x[plant,loc])*1000<=x["Wind Turbine",loc])
	    #@constraint(m,x["Wind Turbine","r2"]==3)
	    #@constraint(m,x["Solar panel","r2"]==3)
	    #@constraint(m,x["Plant","r1"]==1)
	    #@constraint(m,sum(x["Plant",Location])==1)
	    #@constraint(m,trxp[loc in Location,l=1:n_lij],20*nt[trline[findall( x -> x[1] == loc, trline )],l].>=sum(x[:,loc]))
	    #@constraint(m,trxv[loc in Location[2:end],l=1:n_lij],nt[trline[findall( x -> x[2] == loc, trline )],l].<=sum(x[:,loc]))
	    @constraint(m,trx[loc in Location],(sum(nt[(p,v),l] for l in 1:n_lij for (p,v) in trline if v==loc)+sum(nt[(p,v),l] for l in 1:n_lij for (p,v) in trline if p==loc))*2500>=sum(x[:,loc]))
	    
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
	    @constraint(m,modesxy[i in plant,loc in Location,t=1:n_tm],sum(y[i,loc,modes,t])==x[i,loc]*d_m[t]*24)
	    
	    @constraint(m,stoic[i in plant,mod in modes,c in chemical,c1 in chemical,loc in Location,t=1:n_tm],1000*F_1_mod[i,c,loc,mod,t].*α[i,c1,mod]./mw[(c,)].==1000*F_1_mod[i,c1,loc,mod,t].*α[i,c,mod]./mw[(c1,)])
	    @constraint(m,stoichadd[i in plant,c in chemical,loc in Location,t=1:n_tm],F_1[i,c,loc,t].==sum(F_1_mod[i,c,loc,modes,t]))
	    @constraint(m,minp[i in plant,mod in modes,loc in Location,t=1:n_tm],F_1_mod[i,Base_chem[i],loc,mod,t]>=y[i,loc,mod,t].*C_min[(i,Base_chem[i],mod)])
	    @constraint(m,maxp[i in plant,mod in modes,loc in Location,t=1:n_tm],F_1_mod[i,Base_chem[i],loc,mod,t]<=y[i,loc,mod,t].*C_max[(i,Base_chem[i],mod)])
	    
	    @constraint(m,inven1[i in plant,c in chemical,loc in Location],Q_1[i,c,loc,1].==F_1[i,c,loc,1] -sum(Tr_1[i,c,loc,Consumer_supplier,1]))
	    @constraint(m,inven[i in plant,c in chemical,loc in Location,t = 2:n_tm],Q_1[i,c,loc,t].==Q_1[i,c,loc,t-1]+F_1[i,c,loc,t]-sum(Tr_1[i,c,loc,Consumer_supplier,t]))
	   
	    @constraint(m,transdem[j in Consumer_supplier,c in c_jp[(j,)],t = 1:n_tm],sum(Tr_1[plant,c,Location,j,t])+sltr_1[c,j,t]==D[(c,j,t)])
	    @constraint(m,powerel[i in plant,loc in Location,t=1:n_tm],0.1*Po_1[i,loc,t]*1==sum(0.1*F_1_mod[i,Base_chem[i],loc,mod,t]*f_lin[(i,mod)] for mod in modes)+sum(0.1*F_1[i,c,loc,t].*F_comp[(i,c)].*S[(i,c)] for c in chemical))
	    @constraint(m,invenboun2up[i in plant,c in chemical, loc in Location,t=1:n_tm],Q_1[i,c, loc, t] .<=80000* x[i, loc])
	    for mod in modes 
	    	for i in plant
	       		if(C_min[(i,Base_chem[i],mod)]==0 && C_max[(i,Base_chem[i],mod)]==0) 
	       			for t = 1:n_tm
	       				for k = 1:n_k
	       					for h = 1:n_s
	       						for c in chemical
	       							for loc in Location
	    								@constraint(m,F_1_mod[i,c,loc,mod,t]==0)
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
	   


	    @variable(m,Gen[loc in Location,1:n_tm])
	    @variable(m,Dempl[loc in Location,1:n_tm])
	    @constraint(m,gcon[loc in Location,t=1:n_tm],0.1*Gen[loc,t].==0.1*sum(sum(P[(i,loc,t,k,h)]*w[(k,t)] for h in 1:24 for k in 1:n_k).*x[i,loc] for i in powergen)/S_base)
	    @constraint(m,dcon[loc in Location,t=1:n_tm],S_base*Dempl[loc,t].==sum(Po_1[plant,loc,t]))
	    #theta_flow = m[:theta_flow]
	    
	    coc = 1
	    @constraint(m,curtail[loc in Location,t=1:n_tm], p_cu[loc,t] <= Gen[loc,t])
	    @constraint(m,powbaln1[loc in Location,t=1:n_tm],p_cu[loc,t] + Dempl[loc,t].==Gen[loc,t]-sum(p_flow[(p,v),t] for (p,v) in trline if p==loc)) 
	    @constraint(m,powbalru[t=1:n_tm],p_flowext[t]==sum(p_flow[(p,v),t] for (p,v) in trline if p=="ru")) 
	    @constraint(m,powbalru1[t=1:n_tm],p_flowext[t]==0)
	    #@constraint(m,comppow[t=1:n_tm],sum(Gen[Location,t])-sum(Po_1[Location,t])-sum(p_cu[Location,t])>=-p_flowext[t])
	    return m
	end
	m = powerbal(m)
	println("yes")

	function transcon2(m) #Function to add constraints on transmision loss with peice wise linear power loss
	    p_flow= m[:p_flow]
	    
	    n = m[:nt]
	    
	    #p_pos= m[:p_pos]
	    #p_neg= m[:p_neg]
	    lo = 0.95
	    up = 1.05
	   
	    @constraint(m,tr3[(p,v) in trline,t=1:n_tm],-0.1*Fl_max[(p,v)]*n[(p,v)]*24*d_m[t]*per_val.<=0.1*p_flow[(p,v),t]*S_base)
	    @constraint(m,tr4[(p,v) in trline,t=1:n_tm],0.1*p_flow[(p,v),t]*S_base.<=0.1*Fl_max[(p,v)]*n[(p,v)]*24*d_m[t]*per_val)



        @constraint(m,tr18[(p,v) in trline,t=1:n_tm],p_flow[(p,v),t]+p_flow[(v,p),t]>=0)
      
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
	    #nso = m[:n_storage]
	    global matcostc = @expression(m,[i in plant,c in chemical],sum(Tr_1[i,c,:,:,:].*C_c[(c)])-sum(sltr_1[c,:,:].*C_c[(c)]*(sl_fac)))
	    #global matcostnormc = @expression(m,[c in chemical],sum(Tr_1[c,:,:,:].*C_c[(c,)]))
	    global transcostc = @expression(m,[i in plant,c in chemical,j in Consumer_supplier,loc in Location],sum(Tr_1[i,c,loc,j,:].*S[(i,c)].*C_t[(c)].*dist[(loc,j)]))
	    global eleccost = @expression(m,[t = 1:n_tm],sum(w[(k,t)] for h in 1:24 for k in 1:n_k).*p_flowext[t]*elec_fac*S_base/(24*d_m[t]))
	    global FIXOP = @expression(m,[i in component],sum(FOC[(i)].*x[i,:])/n_m)
	    global FIXOP_l = @expression(m,[(p,v) in trline],sum(FOC_l[(p,v)].*n[(p,v)])/(2*n_m))
	    global CAPEX = @expression(m,[i in component],sum(DIC[(i)].*x[i,:])/n_m)
	    global CAPEX_l = @expression(m,[(p,v) in trline],sum(DIC_l[(p,v)].*n[(p,v)])/(2*n_m))
	    #global CAP_st = @expression(m,[i in storage],sum(DIC[(i)].*nso[i,:])/(n_m*2))
	    #@constraint(m,sum(CAPEX) <= (DIC[("Plant",)]+ 2*DIC[("Solar panel",)]+5*DIC[("Wind Turbine",)])/6) #Investment related constraint

	    @objective(m,Min,-(sum(matcostc)-sum(transcostc)-sum(eleccost)-sum(FIXOP)-sum(FIXOP_l)-sum(CAPEX)-sum(CAPEX_l))/1000)
	    #@objective(m,Max,(sum(matcostc)-sum(transcostc)-sum(eleccost)-sum(FIXOP)-sum(CAPEX))/1000)
	    #@objective(m,Max,sum(matcostc))
	    return m
	end
	#print(values(P))
	m = obj(m)
	return m
end