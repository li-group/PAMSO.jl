module PAMSO
using NOMAD
#using BayesOpt
#using Optim
# Write your package code here.
#module PAMSO
export PAMSO_block
export run
mutable struct PAMSO_block
    high_level_model::Function
    low_level_model::Function
    algo::String
    dimmensions::Int
    input_types::Vector
    lb::Vector	
    ub::Vector
    init::Vector
    MBBF::Function
    Param_best::Vector
    func_eval::Int	

    function PAMSO_block(high_level_model,low_level_model,algo,dimmensions,input_types,lb,ub,init,func_eval)
    	function MBBF(x)
    		high_level_des = high_level_model(x)
 		obj = low_level_model(high_level_des)
 		return obj
 	end

	    	
	    new(high_level_model,low_level_model,algo,dimmensions,input_types,lb,ub,init,MBBF,[],func_eval)
	end


end


function run(PAMSO_block)
	if(PAMSO_block.algo=="MADS")

		function bb(x)
		  f =  PAMSO_block.MBBF(x)
		 # c = 1 - x[1]
		  success = true
		  count_eval = true
		  bb_outputs = [f]
		  return (success, count_eval, bb_outputs)
		end
		p = NomadProblem(PAMSO_block.dimmensions, 1, ["OBJ"], bb, input_types = PAMSO_block.input_types	,
		                lower_bound=PAMSO_block.lb,
		                upper_bound=PAMSO_block.ub,initial_mesh_size = (PAMSO_block.ub-PAMSO_block.lb)*0.5)
		p.options.display_degree = 2
		p.options.sgtelib_model_max_eval = PAMSO_block.func_eval
		p.options.max_bb_eval = PAMSO_block.func_eval
		p.options.display_stats = ["BBE","BBO","ITER_NUM","OBJ","SOL","TIME","TOTAL_SGTE"]
		#p.BBInputTypes = ["I","I","R"]
		result = solve(p, PAMSO_block.init)
		PAMSO_block.Param_best = result.x_best_feas
	elseif(PAMSO_block.algo=="Bayesopt")
		if("I" in PAMSO_block.input_types)
			println("Wrong algorithm. Use MADS")
		else

			config = ConfigParameters()         
			set_kernel!(config, "kMaternARD5")  
			config.sc_type = SC_MAP
			config.n_iterations = PAMSO_block.func_eval-10
			config.force_jump = 10
			#config.n_init_samples = [0.0,0.0,0.0,0.0,1.0,0.0]
			lowerbound = PAMSO_block.lb; upperbound = PAMSO_block.ub
			optimizer, optimum = bayes_optimization(PAMSO_block.MBBF, lowerbound, upperbound, config)
			PAMSO_block.Param_best = optimizer
		end
	elseif(PAMSO_block.algo=="PSO")
		if("I" in PAMSO_block.input_types)
			println("Wrong algorithm. Use MADS")
		else
			o = Optim.Options(iterations = PAMSO_block.func_eval/15-1)
			res = optimize(PAMSO_block.MBBF,PAMSO_block.lb, PAMSO_block.ub, PAMSO_block.init, ParticleSwarm(;lower,upper,n_particles = 15),o)
			PAMSO_block.Param_best = Optim.minimizer(res)
		end
	else
		println("Error")
	end
end

	


end
