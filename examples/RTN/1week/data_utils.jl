using DataFrames
using StatsBase
using XLSX
using DataStructures

function create_model_data(task, resources, network, sd_set, H, days, num_day_week)
    I = []
    R = []
    Rp = []
    nodes = []
    Task_resources = []
    unit_to_resource_mapping = Dict()
    R_type = Dict()
    R_cost = Dict()
    X_cost = Dict()
    tau = Dict()  # Duration of task
    X0 = Dict()   # Initial resource level
    Xmin = Dict() # Minimum resource level
    Xmax = Dict() # Maximum resource level
    N_cost = Dict()
    idx = []
    idx_reac = []
    mu = Dict()
    nu = Dict()
    nu_reac = Dict()

    pi = Dict()
    max_tau = 0

    horizon = H
    N = []
    for i in 1:length(names(network))
        push!(N,i)
    end
    
    T = []
    for i in 1:length(names(task))
        push!(T,i)
    end
    Res = []
    for i in 1:length(names(resources))
        push!(Res,i)
    end

    graph = DefaultDict(list)

    for i in 1:size(resources, 1)
      
        push!(nodes, resources[i,Res[1]])
        push!(R, resources[i,Res[1]])
        
        X0[resources[i,Res[1]]] = resources[i,Res[2]]
        R_type[resources[i,Res[1]]] = resources[i,Res[6]]
        R_cost[resources[i,Res[1]]] = resources[i,Res[7]]
        X_cost[resources[i,Res[1]]] = resources[i,Res[8]]
        
        Xmin[resources[i,Res[1]]] = resources[i,Res[3]]
        Xmax[resources[i,Res[1]]] = resources[i,Res[4]]
        if resources[i,Res[5]] == 1
            push!(Task_resources, resources[i,Res[1]])
        end
        if resources[i,Res[6]] == "Product"
            push!(Rp, resources[i,Res[1]])
        end
    end
    
    for u in Task_resources
        unit_to_resource_mapping[u] = []
    end

    for i in 1:size(task, 1)
        push!(nodes, task[i,T[1]])
        push!(I, task[i,T[1]])
        
        tau[task[i,T[1]]] = task[i,T[2]]
        N_cost[task[i,T[1]]] = task[i,T[4]]
        if tau[task[i,T[1]]] > max_tau
            max_tau = tau[task[i,T[1]]]
        end
        push!(unit_to_resource_mapping[task[i,T[3]]], task[i,T[1]])
    end
    
    for i in 1:size(network, 1)
        a = network[i,N[1]]
        b = network[i,N[2]]
        if a in R
            nu_reac[b, a] = network[i,N[3]]
            push!(idx_reac, (b, a))
        else
            nu_reac[a, b] = network[i,N[3]]
            push!(idx_reac, (a, b))
        end
    end
    for i in 1:size(network, 1)
        if network[i,N[1]] in I
            if !(network[i,N[2]] in Task_resources)
                for theta in 0:tau[network[i,N[1]]]
                    mu[(network[i,N[1]], network[i,N[2]], theta)] = 0
                    if theta == tau[network[i,N[1]]]
                        nu[(network[i,N[1]], network[i,N[2]], theta)] = network[i,N[3]]
                    else
                        nu[(network[i,N[1]], network[i,N[2]], theta)] = 0
                    end
                    push!(idx, (network[i,N[1]], network[i,N[2]], theta))
                end
            else
                for theta in 0:tau[network[i,N[1]]]
                    nu[(network[i,N[1]], network[i,N[2]], theta)] = 0
                    if theta == 0
                        mu[(network[i,N[1]], network[i,N[2]], theta)] = -network[i,N[3]]
                    elseif theta == tau[network[i,N[1]]]
                        mu[(network[i,N[1]], network[i,N[2]], theta)] = network[i,N[3]]
                    else
                        mu[(network[i,N[1]], network[i,N[2]], theta)] = 0
                    end
                    push!(idx, (network[i,N[1]], network[i,N[2]], theta))
                end
            end
            if !(network[i,N[2]] in keys(graph))
                graph[network[i,N[2]]] = []
            end
            push!(graph[network[i,N[2]]],network[i,N[1]])
        else
            for theta in 0:tau[network[i,N[2]]]
                mu[(network[i,N[2]], network[i,N[1]], theta)] = 0
                if theta == 0
                    nu[(network[i,N[2]], network[i,N[1]], theta)] = network[i,N[3]]
                else
                    nu[(network[i,N[2]], network[i,N[1]], theta)] = 0
                end
                if length(N) > 3 && theta == tau[network[i,N[2]]]
                    nu[(network[i,N[2]], network[i,N[1]], theta)] = network[i,N[4]]
                end
                push!(idx, (network[i,N[2]], network[i,N[1]], theta))
            end
            
            if !(network[i,N[1]] in keys(graph))
                graph[network[i,N[1]]] = []
            end
            push!(graph[network[i,N[1]]],network[i,N[2]])
        end
    end

    
    weeks = length(sd_set)
    for i in R
        for t in 1:days
            pi[(i, t)] = 0
        end
    end
    for i in 1:weeks
        sd = sd_set[i]

        for j in 1:length(Rp) * num_day_week
            pi[(sd[j,1], sd[j,3]+num_day_week*(i-1))] = sd[j,2] 
        end
    end
    
   
    data = Dict(
        "tau" => tau,
        "X0" => X0,
        "Xmin" => Xmin,
        "Xmax" => Xmax,
        "mu" => mu,
        "nu" => nu,
        "pi" => pi,
        "I" => I,
        "R" => R,
        "idx" => idx,
        "max_tau" => max_tau,
        "graph" => graph,
        "horizon" => horizon,
        "Task_resources" => Task_resources,
        "unit_to_resource_mapping" => unit_to_resource_mapping,
        "R_type" => R_type,
        "X_cost" => X_cost,
        "R_cost" => R_cost,
        "days" => days,
        "Rp" => Rp,
        "nu_reac" => nu_reac,
        "idx_reac" => idx_reac,
        "num_day_week" => num_day_week,
        "N_cost" => N_cost,
    )

    return data
end

