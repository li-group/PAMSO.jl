root = pwd()
using PAMSO
#include("full_space_model.jl")
include("high_level_model.jl")
include("low_level_model.jl"))

mutable struct Gen_exp((MModel))
	algo::String
	PAMSO_problem::PAMSO_block
	high_level_model::function
	low_level_model::function
	integrated_model::function
	
	struct PAMSO_params
	initial_value::[]
	upper
	lower
end

struct Benders_params
	intia =

get_intial()
set_

	# PAMSO_problem = PAMSO.PAMSO_block(gen_highlevel, gen_lowlevel, algo, 3, ["R","R","R"],[0.0,0.0,0.0],[10.0,10.0,1000.0],[1.0,1.0,0.0],300)
	function Gen_exp(algo,PAMSO_problem)
		new(algo,PAMSO_problem)
	end

end

input = "Gen_exp"
run!(...)


basecase Mmodel: (members: high_level_model::JuMP., low_level_model)

PAMSO_problem = PAMSO.PAMSO_block(case="RTN")
PAMSO_problem.solve()
