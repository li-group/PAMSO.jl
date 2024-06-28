module PAMSO
using NOMAD
using JuMP
using BayesOpt
using Optim
# Write your package code here.
#module PAMSO

export PAMSO_block
export PAMSO_params
export run
export gen_problem
export set_initparams
export set_inputtype
export set_hlmodel
export set_llmodel
export set_fsmodel
export set_lb
export set_ube

struct PAMSO_params
	init::Vector
	lb::Vector
	ub::Vector
	input_types::Vector

	function PAMSO_params(init,lb,ub,input_types)
		new(init,lb,ub,input_types)
	end
end




mutable struct PAMSO_block
    high_level_model::Function
    low_level_model::Function
    full_space_model::JuMP.Model
    MBBF::Function
    dimmensions::Int
    param::PAMSO_params
    Param_best::Vector	

    function PAMSO_block(high_level_model,low_level_model,full_space_model,dimmensions,params)
    	function MBBF(x)
    		high_level_des = high_level_model(x)
 			obj = low_level_model(high_level_des)
 		return obj
 	end

	    	
	    new(high_level_model,low_level_model,full_space_model,MBBF,dimmensions,params,[])
	end


end


function solve(PAMSO_block,algo,func_eval)
	if(algo=="MADS")

		function bb(x)
		  f =  PAMSO_block.MBBF(x)
		 # c = 1 - x[1]
		  success = true
		  count_eval = true
		  bb_outputs = [f]
		  return (success, count_eval, bb_outputs)
		end
		p = NomadProblem(PAMSO_block.dimmensions, 1, ["OBJ"], bb, input_types = PAMSO_block.param.input_types	,
		                lower_bound=PAMSO_block.param.lb,
		                upper_bound=PAMSO_block.param.ub,initial_mesh_size = (PAMSO_block.param.ub-PAMSO_block.param.lb)*0.5)
		p.options.display_degree = 2
		p.options.sgtelib_model_max_eval = func_eval
		p.options.max_bb_eval = func_eval
		p.options.display_stats = ["BBE","BBO","ITER_NUM","OBJ","SOL","TIME","TOTAL_SGTE"]
		#p.BBInputTypes = ["I","I","R"]
		result = solve(p, PAMSO_block.param.init)
		PAMSO_block.Param_best = result.x_best_feas
	elseif(algo=="Bayesopt")
		if("I" in PAMSO_block.param.input_types)
			println("Wrong algorithm. Use MADS")
		else

			config = ConfigParameters()         
			set_kernel!(config, "kMaternARD5")  
			config.sc_type = SC_MAP
			config.n_iterations = func_eval-10
			config.force_jump = 10
			#config.n_init_samples = [0.0,0.0,0.0,0.0,1.0,0.0]
			lowerbound = PAMSO_block.param.lb; upperbound = PAMSO_block.param.ub
			optimizer, optimum = bayes_optimization(PAMSO_block.MBBF, lowerbound, upperbound, config)
			PAMSO_block.Param_best = optimizer
		end
	elseif(algo=="PSO")
		if("I" in PAMSO_block.param.input_types)
			println("Wrong algorithm. Use MADS")
		else
			lower = PAMSO_block.param.lb
			upper = PAMSO_block.param.ub
			o = Optim.Options(iterations = max(trunc(Int,func_eval/20)-1,1))
			res = optimize(PAMSO_block.MBBF,lower, upper, PAMSO_block.param.init, ParticleSwarm(;lower,upper,n_particles=20),o)
			PAMSO_block.Param_best = Optim.minimizer(res)
		end
	else
		println("Error")
	end
end

	
function set_initparams(PAMSO_block,init)
	PAMSO_block.params.init = init
end

function set_lb(PAMSO_block,lb)
	PAMSO_block.params.lb = lb
end

function set_ub(PAMSO_block,ub)
	PAMSO_block.params.ub = ub
end

function set_inputtype(PAMSO_block,input_types)
	PAMSO_block.params.input_types = input_types
end

function set_hlmodel(PAMSO_block,high_level_model)
	PAMSO_block.high_level_model = high_level_model
end
function set_llmodel(PAMSO_block,low_level_model)
	PAMSO_block.low_level_model = low_level_model
end
function set_fsmodel(PAMSO_block,full_space_model)
	PAMSO_block.full_space_model = full_space_model
end

function gen_problem(case)
     src_dir = @__DIR__
     println(pwd())	
     #cd("../")
     if(case == "Generator_expansion")
		cd(joinpath(src_dir, "..", "examples","Generator_expansion"))
	    	include("full_space_model.jl")
		include("high_level_model.jl")
		include("low_level_model.jl")
		params = PAMSO_params([1.0,1.0,0.0],[0.0,0.0,0.0],[10.0,10.0,1000.0], ["R","R","R"])
		PAMSO_problem = PAMSO_block(gen_highlevel, gen_lowlevel, fs_model, 3, params)
		cd(src_dir)
		return PAMSO_problem
	end



end




end
