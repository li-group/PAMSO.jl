using JuMP
using Gurobi
using XLSX
mutable struct RTN_agg
    data::Dict
end
    


        

function solve_model_agg(RTN_agg, x)
    Feed_tasks = []
    Product_tasks = []
    Intermediate_tasks = []
    Feed_vessels = []
    Product_vessels = []
    Intermediate_vessels = []
   
    param_n = x[6]
    param_dof = x[2]
    param_dop = x[3]
    param_doi = x[4]
    param_b1 = x[1]
    param_x = x[5]
    
    column(x::VariableRef) = Gurobi.c_column(backend(owner_model(x)), index(x))
    m = direct_model(Gurobi.Optimizer())
    
    set_optimizer_attribute(m,"TimeLimit",150)
   
    set_optimizer_attribute(m,"PreSolve",2)
    set_optimizer_attribute(m,"Threads",8)
    set_optimizer_attribute(m,"MIPGap",0.03)

    data = RTN_agg.data
    I = data["I"]
        R = data["R"]
        idx = data["idx"]
        mu = data["mu"]
        nu = data["nu"]
        tau = data["tau"]
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
        pen = data["pen"]

        T = collect(0:days)
        T1 = collect(1:days) 
        Td = collect(1:days)

        Ir = Dict()

# Loop through each key-value pair in self.graph
for (r, value) in graph
    # Add the key-value pair to the new dictionary
    Ir[r] = value
end

    @variable(m, 0<=X[r in R,t in T])
    for r in R
        if r in Task_resources
            @constraint(m,X[r,0]==X0[r]*24)
        else
            @constraint(m,X[r,0]==X0[r])
        end
    end
    @variable(m, 0<=N[i in I,t in T1]<=24,Int)
    for i in I, t in T1
        @constraint(m,N[i,t]<=24/tau[i])
    end
    @variable(m, 0<=E[i in I,t in T1])
    @variable(m, pi[r in R,t in T1])
    @variable(m, 0<=sl[r in Rp,n in Td])
    @variable(m, 0<=Vmax[r in Task_resources]<=1000)
    @variable(m, 0<=Vmax_pow[r in Task_resources])
    
    R_mat = []
    for r in R
        if (R_type[r] != "Vessel")
            push!(R_mat,r)
        end
    end
    @variable(m, 0<=Xmax_val[r in R_mat]<=100)
    @variable(m, 0<=Xmax_pow[r in R_mat])
    for r in Task_resources
        GRBaddgenconstrPow(backend(m), "pow", column(Vmax[r]), column(Vmax_pow[r]), 0.6, "")
    end
    for r in R_mat
        GRBaddgenconstrPow(backend(m), "pow", column(Xmax_val[r]), column(Xmax_pow[r]), 0.6, "")
    end

    for r in R
        if(R_type[r]=="Feed")
            for i in Ir[r]
                push!(Feed_tasks,i)
            end
        elseif(R_type[r]=="Product")
            for i in Ir[r]
                push!(Product_tasks,i)
            end
        else
            for i in Ir[r]
                push!(Intermediate_tasks,i)
            end
        end
    end
    for r in Task_resources
            a = 0
            b = 0
            c = 0
            for i in Ir[r]
                if(i in Feed_tasks)
                    a = 1
                end
                if(i in Product_tasks)
                    b = 1
                end
                if(i in Intermediate_tasks)
                    c = 1
                end
            end
                if(a==1)
                    push!(Feed_vessels,r)
                elseif(b==1)
                    push!(Product_vessels,r)
                else
                    push!(Intermediate_vessels,r)
                end
    end

    for r in R
            if(R_type[r] == "Feed")
                for t in T1
                    @constraint(m,pi[r, t] >= 0)
                end
            elseif(R_type[r] == "Product")
                    for t in T1
                    @constraint(m,pi[r, t] <= 0)
                end
                for n in Td
                    
                    @constraint(m,-1*pi[r,n]== Dem[r, n] - sl[r, n]*1)
                end      
                    
            else
                for t in T1
                    @constraint(m,pi[r, t] == 0)
                end
            end 
    end
        
        for t in T1
            for r in R
                if !(r in Task_resources)                
                    @constraint(m,X[r, t]== X[r, t - 1]+ sum(nu_reac[i, r] * E[i, t] for i in Ir[r])+ pi[r, t])
                end
            end
        end


    for t in T1
            for r in R
                @constraint(m,X[r, t] >= Xmin[r])
            end
    end
        for t in T1
            for r in R
                if(r in Task_resources)
                    @constraint(m,X[r, t] <= Xmax[r])
                else
                    @constraint(m,X[r, t] <= Xmax_val[r])
                    @constraint(m,Xmax_val[r] <= Xmax[r])
                end
            end
        end

        for r in R
            if !(r in Task_resources)
                for n in 0:weeks
                    @constraint(m,X[r, num_day_week*n]==0)
                end
            end
        end

        for u in Task_resources
            for t in T1
                for i in unit_to_resource_mapping[u]
                    @constraint(m,Vmax[u] * N[i, t]*1.0 >= E[i, t])
                    @constraint(m,Vmax[u] * N[i, t] * 0.5 <= E[i, t])
        
                end
                @constraint(m,sum(N[i, t]*tau[i] for i in unit_to_resource_mapping[u]) <= 24)
            end
        end
   
    

    obj = (
        sum(N[i, t]*N_cost[i] for i in I for t in T1)*param_n +
        sum(pi[r, t] * R_cost[r] for r in R for t in T1) +
        param_b1*pen*sum(sl[r, t] * R_cost[r] for r in Rp for t in Td) +
        sum(Vmax_pow[r] * R_cost[r] * param_dof* weeks  for r in Feed_vessels) +
        sum(Vmax_pow[r] * R_cost[r] * param_dop* weeks  for r in Product_vessels) +
        sum(Vmax_pow[r] * R_cost[r] * param_doi* weeks for r in Intermediate_vessels) +
        sum(Xmax_pow[r] * X_cost[r]*param_x * weeks for r in R_mat)
    )
    @objective(m, Min, obj)


   

    optimize!(m)

    
    V_max = Dict(r => value.(Vmax[r]) for r in Task_resources)
    Xmax_set = Dict(r => value.(Xmax_val[r]) for r in R_mat)
    println(value.(sl))
    return m, V_max, Xmax_set
end
