function gen_lowlevel(high_level_des)
	println(high_level_des)
	x_des = high_level_des['x']
	model = Model(Gurobi.Optimizer)
	set_optimizer_attribute(model,"PreSolve",2)
	@variable(model, x[gen] >= 0)  # Installed capacity of generator j
	@variable(model, y[totalScenarios, timePeriods, gen] >= 0)  # Operating level of generator j
	@variable(model, y_purchased[totalScenarios, timePeriods] >= 0)  # Additional capacity purchased

	# Objective function
	@objective(model, Min, sum(c[j] * x[j] for j in gen) +
	           sum(p[a, b, c, d, e] * sum(sum(f[(j, i)] * y[(a, b, c, d, e), i, j] for j in gen) + g[i] * y_purchased[(a, b, c, d, e), i]  for i in timePeriods) for (a, b, c, d, e) in totalScenarios))

	# Constraints

	# Demand satisfaction constraints
	@constraint(model, [i in demandScenario_1, j in demandScenario_2, k in demandScenario_3, l in A1, m in A2, t in timePeriods],
	    sum(y[(i, j, k, l, m), t, gen] for gen in gen) + y_purchased[(i, j, k, l, m), t] >= d[(t, (i, j, k, l, m))])

	# Availability constraints
	@constraint(model, [i in demandScenario_1, j in demandScenario_2, k in demandScenario_3, l in A1, m in A2, t in timePeriods, gen in gen],
	    y[(i, j, k, l, m), t, gen] <= a[(gen, (i, j, k, l, m))] * x[gen])
	@constraint(model,x.==x_des)
	# Solve the model
	optimize!(model)
	
	# Display the results
	println("Objective value: ", objective_value(model))
	println("x values: ", value.(x))
	return  objective_value(model)
end