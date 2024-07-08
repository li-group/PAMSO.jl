using JuMP
using Gurobi
using DataFrames

struct RTN
    data::Dict 
end

function solve_model_full(rtn::RTN,ret_mod = 0,Vmaxval = Nothing,Xmaxval = Nothing)
    m = direct_model(Gurobi.Optimizer())
    column(x::VariableRef) = Gurobi.c_column(backend(owner_model(x)), index(x))
    
    set_optimizer_attribute(m,"PreSolve",2)
    set_optimizer_attribute(m,"TimeLimit",150)
    #set_optimizer_attribute(m,"LogFile","7day_full_1.txt")
    #set_optimizer_attribute(m,"LogFile","1week_algo2.txt")
    #set_optimizer_attribute(m,"LogFile","7day4week_full_4_exp6_1_algodis.txt")
    set_optimizer_attribute(m,"Threads",8)
    set_optimizer_attribute(m,"MIPGap",0.02)

    # Defining sets and parameters
    
    data = rtn.data
    I = data["I"]
        R = data["R"]
        idx = data["idx"]
        mu = data["mu"]
        nu = data["nu"]
        tau = data["tau"]
        #Vmax = data["Vmax"]
        #Vmin = data["Vmin"]
        X0 = data["X0"]
        Xmin = data["Xmin"]
        Xmax = data["Xmax"]
        Dem = data["pi"]
        max_tau = data["max_tau"]
        horizon = data["horizon"]
        graph = data["graph"]
        Task_resources = data["Task_resources"]
        R_type = data["R_type"]
        R_cost = data["R_cost"]
        X_cost = data["X_cost"]
        days = data["days"]
        Rp = data["Rp"]
        unit_to_resource_mapping = data["unit_to_resource_mapping"]
        nu_reac = data["nu_reac"]
        idx_reac = data["idx_reac"]
        num_day_week = data["num_day_week"]
        weeks = Int(days/num_day_week)
        N_cost = data["N_cost"]


    T = collect(0:horizon)
    T1 = collect(1:horizon) 
    Td = collect(1:days)
    Ir = Dict()
    for (r, value) in graph
    # Add the key-value pair to the new dictionary
    Ir[r] = value
end
    R_mat = []
        for i in R
            if (R_type[i] != "Vessel")
                push!(R_mat,i)
            end
        end

    # Defining variables
    @variable(m, X[r in R, t in T] >= 0)
    for r in R
        if r in keys(X0)
            @constraint(m, X[r, 0] == X0[r])
        end
    end

    @variable(m, N[i in I, t in T1], Bin)
    @variable(m, E[i in I, t in T1] >= 0)
    @variable(m, pi[r in R, t in T1])

    # Defining intermediate variables
    @variable(m, sl[r in Rp, n in Td] >= 0)
    @variable(m, Vmax[r in Task_resources] >= 0)
    @variable(m, Vmax_pow[r in Task_resources] >= 0)
    @variable(m,Xmax_val[r in R_mat]>=0)
    @variable(m,Xmax_pow[r in R_mat]>=0)

   
    
    if Vmaxval!= Nothing
            for r in keys(Vmaxval)
                @constraint(m,Vmax[r] == min(1000,Vmaxval[r]))
                @constraint(m,Vmax_pow[r] == min(1000,max(0,Vmaxval[r]))^0.6)
            end
        else
             for r in Task_resources
                 GRBaddgenconstrPow(backend(m), "pow", column(Vmax[r]), column(Vmax_pow[r]), 0.6, "")
             end
    end
        if Xmaxval!=Nothing
            for r in keys(Xmaxval)
                @constraint(m,Xmax_val[r] == min(Xmaxval[r],100))
                @constraint(m,Xmax_pow[r] == min(max(0,Xmaxval[r]),100)^0.6)
            end
        else
            for r in R_mat
        GRBaddgenconstrPow(backend(m), "pow", column(Xmax_val[r]), column(Xmax_pow[r]), 0.6, "")
    end
        end
    println(length(keys(nu)))
    println(length(keys(mu)))
    # Defining constaints
   # @constraint(m,sum(sl)<=sum(values(Dem))*0.6)
   println(Dem)
    for r in R
        if R_type[r] == "Feed"
            for t in T1
                @constraint(m, pi[r, t] >= 0)
            end
        elseif R_type[r] == "Product"
            #@constraint(m,pi[r,0]==0)
            for t in T1
                @constraint(m, pi[r, t] <= 0)
            end
            for n in Td
                @constraint(m, sum(-1*pi[r, t] for t in collect((24 * (n - 1) + 1):(24 * n))) == Dem[r,n] - sl[r, n])
            end
        else
            for t in T1
                @constraint(m, pi[r, t] == 0)
            end
        end
    end
    println(tau["CD"])
    for t in T1
        for r in R
                @constraint(m, X[r, t] == X[r, t - 1] + sum(mu[i, r, theta] * N[i, t - theta] + nu[i, r, theta] * E[i, t - theta] for i in Ir[r], theta in 0:max_tau if theta <= tau[i] && t-theta >=1)+pi[r,t])
        end
    end

    for t in T1
        for r in R
            @constraint(m, X[r, t] >= Xmin[r])
        end
    end

    for t in T1
        for r in Task_resources
            @constraint(m, X[r, t] <= Xmax[r])
        end
        for r in R_mat
            @constraint(m, X[r, t] <= Xmax_val[r])
            @constraint(m, Xmax_val[r] <= Xmax[r])
            #@constraint(m, X[r, t] <= 100)
        end
    end

    for u in Task_resources
        for t in T1
            for i in unit_to_resource_mapping[u]
                @constraint(m, Vmax[u] * N[i, t] >= E[i, t])
                @constraint(m, Vmax[u] * N[i, t] * 0.5 <= E[i, t])
                #@constraint(m, 0.0001 * N[i, t] * 0.5 <= Vmax[u])
            end
            @constraint(m, sum(N[i, t] for i in unit_to_resource_mapping[u]) <= 1)
        end
    end

    # Defining objective
   @objective(m, Min, sum(N[i, t]*N_cost[i] for i in I for t in T1) +
              sum(pi[r, t] * R_cost[r] for r in R for t in T1) +
              2 * sum(sl[r, t] * R_cost[r] for r in Rp for t in Td) +
              sum(Vmax_pow[r] * R_cost[r]  for r in Task_resources)*weeks+
              sum(Xmax_pow[r] * X_cost[r] for r in R_mat)*weeks)

   
    

    

   
   if(ret_mod==1)
        return m
    end
    
    optimize!(m)
   println(sum(value.(pi)))
    println(R_type)
    println(X0)
    println("Objective Value: ", objective_value(m))
    println("Vmax: ", value.(Vmax))
    println("Slack: ", value.(sl))
    println("Vmax_pow: ", value.(Vmax_pow))
    println(Xmaxval)
    println(mu)
    println(nu)
    return objective_value(m)
end
