using JuMP
using Gurobi
using DataFrames
import XLSX

# Create a model


# 5D Array
gen = [1, 2]  # Generators
timePeriods = [1, 2, 3]  # Time periods
demandScenario_1 = [1, 2, 3, 4]  # Demand scenario for time period 1
demandScenario_2 = [1, 2, 3, 4]  # Demand scenario for time period 2
demandScenario_3 = [1, 2, 3, 4]  # Demand scenario for time period 3
A1 = [1, 2, 3, 4]  # Availability scenarios for Generator 1
A2 = [1, 2, 3, 4, 5]  # Availability scenarios for Generator 2

# Total Scenarios
totalScenarios = [(i, j, k, l, m) for i in demandScenario_1 for j in demandScenario_2 for k in demandScenario_3 for l in A1 for m in A2]

# Load data from Excel
file_path = "data.xlsx"
#file_path = joinpath(root,"Gen_expansion","cap_expan_data_7.xlsx")

# Load the data into DataFrames
dic_df = DataFrame(XLSX.readtable(file_path, "DIC"))
fixop_df = DataFrame(XLSX.readtable(file_path, "FIXOP"))
additional_cost_df = DataFrame(XLSX.readtable(file_path, "Additional cost"))
demand_df = DataFrame(XLSX.readtable(file_path, "Demand"))
gen1_avail_df = DataFrame(XLSX.readtable(file_path, "Gen1_availibility"))
gen2_avail_df = DataFrame(XLSX.readtable(file_path, "Gen2_availiability"))

# Parameters
c = Dict(row.Generator => row["Ammortized Fixed operating cost(\$)"] for row in eachrow(dic_df))
b = Dict(row.Generator => row["Minimum capacity"] for row in eachrow(dic_df))
f = Dict((row.Generator, row.time) => row.FIXOP for row in eachrow(fixop_df))
g = Dict(row.Time => row.Cost for row in eachrow(additional_cost_df))

prob = Dict(
    "Demand_time_1" => Dict(),
    "Demand_time_2" => Dict(),
    "Demand_time_3" => Dict(),
    "A1" => Dict(),
    "A2" => Dict()
)

d = Dict{Tuple{Int, Tuple{Int, Int, Int, Int, Int}}, Float64}()

# Process demand data
for row in eachrow(demand_df)
    t = row.Time
    scenario = row.Scenario
    prob["Demand_time_$(t)"][scenario] = row.Probability
    for i in 1:4, j in 1:4, k in 1:4, l in 1:4, m in 1:5
        if t == 1
            d[(t, (scenario, i, j, k, m))] = row["Demand (KWh)"]
        elseif t == 2
            d[(t, (i, scenario, j, k, m))] = row["Demand (KWh)"]
        elseif t == 3
            d[(t, (i, j, scenario, k, m))] = row["Demand (KWh)"]
        end
    end
end

# Process availability data
a = Dict{Tuple{Int, Tuple{Int, Int, Int, Int, Int}}, Float64}()

for row in eachrow(gen1_avail_df)
    scenario = row.Scenario
    prob["A1"][scenario] = row.Probability
    for i in 1:4, j in 1:4, k in 1:4, m in 1:5
        a[(1, (i, j, k, scenario, m))] = row.Availibility
    end
end

for row in eachrow(gen2_avail_df)
    scenario = row.Scenario
    prob["A2"][scenario] = row.Probability
    for i in 1:4, j in 1:4, k in 1:4, l in 1:4
        a[(2, (i, j, k, l, scenario))] = row.Availibility
    end
end

# Calculate probabilities
p = Dict{Tuple{Int, Int, Int, Int, Int}, Float64}()
for i in keys(prob["Demand_time_1"]), j in keys(prob["Demand_time_2"]), k in keys(prob["Demand_time_3"]), m in keys(prob["A1"]), n in keys(prob["A2"])
    p[(i, j, k, m, n)] = prob["Demand_time_1"][i] * prob["Demand_time_2"][j] * prob["Demand_time_3"][k] * prob["A1"][m] * prob["A2"][n]
end
D = sum(d[(t, (i, j, k, l, m))]*p[i, j, k, l, m] for i in demandScenario_1 for j in demandScenario_2 for k in demandScenario_3 for l in A1, m in A2 for t in timePeriods)
A = Dict()
for g in gen
    A[g] = sum(a[(g, (i, j, k, l, m))]*p[i, j, k, l, m] for i in demandScenario_1 for j in demandScenario_2 for k in demandScenario_3 for l in A1, m in A2)
end
G = sum(g[i] for i in timePeriods)
# JuMP Parameters
function gen_highlevel(param)
    d_param = param[1]
    model = Model(Gurobi.Optimizer)
    @variable(model, x[gen] >= 0)  # Installed capacity of generator j
    @variable(model, y[gen] >= 0)  # Operating level of generator j
    @variable(model, y_purchased >= 0)  # Additional capacity purchased

    # Objective function
    @objective(model, Min, sum(c[j] * x[j] for j in gen) +
                sum(sum(f[(j, i)] * y[j] for j in gen)  for i in timePeriods)+G * y_purchased)

    # Constraints

    # Demand satisfaction constraints
    @constraint(model,sum(y[j] for j in gen) + y_purchased>= D*d_param)
    @constraint(model,[j in gen],x[j]>=b[j])
    @constraint(model,[j in gen],x[j]>=param[3])

    # Availability constraints
    @constraint(model, [j in gen],y[j] <= A[j] * x[j]*3*param[2])

    # Solve the model
    optimize!(model)

# Display the results
    println("Objective value: ", objective_value(model))
    println("x values: ", value.(x))
    high_level_des = Dict()
    high_level_des['x'] = value.(x)
    println()
    return high_level_des
end
#println("y values: ", value.(y))
#println("y_purchased values: ", value.(y_purchased))


