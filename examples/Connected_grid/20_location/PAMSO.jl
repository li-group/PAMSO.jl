#module PAMSO
using NOMAD
using BayesOpt
using Optim
using Dates
using DataFrames
using CSV
using Statistics
using Clustering
using FileIO
using JuMP
import Gurobi
using Optim
import XLSX
import Distributions: Uniform
using Serialization
mutable struct PAMSO
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

    function PAMSO(high_level_model,low_level_model,algo,dimmensions,input_types,lb,ub,init,func_eval)
    	function MBBF(x)
    		high_level_des = high_level_model(x)
 			obj = low_level_model(high_level_des)
 			#outp = DataFrame(A = obj,B = x[1],C = x[2])
    		#CSV.write("Gen_expansion/results_exp4.csv",outp,append = true)
 			return obj
 		end

	    	
	    new(high_level_model,low_level_model,algo,dimmensions,input_types,lb,ub,init,MBBF,[],func_eval)
	end


end


function run(PAMSO)
	if(PAMSO.algo=="MADS")

		function bb(x)
		  f =  PAMSO.MBBF(x)
		 # c = 1 - x[1]
		  success = true
		  count_eval = true
		  bb_outputs = [f]
		  return (success, count_eval, bb_outputs)
		end
		p = NomadProblem(PAMSO.dimmensions, 1, ["OBJ"], bb, input_types = PAMSO.input_types	,
		                lower_bound=PAMSO.lb,
		                upper_bound=PAMSO.ub,initial_mesh_size = (PAMSO.ub-PAMSO.lb)*0.5)
		p.options.display_degree = 2
		p.options.sgtelib_model_max_eval = PAMSO.func_eval
		p.options.max_bb_eval = PAMSO.func_eval
		p.options.display_stats = ["BBE","BBO","ITER_NUM","OBJ","SOL","TIME","TOTAL_SGTE"]
		#p.BBInputTypes = ["I","I","R"]
		result = solve(p, PAMSO.init)
		PAMSO.Param_best = result.x_best_feas
	elseif(PAMSO.algo=="Bayesopt")
		if("I" in PAMSO.input_types)
			println("Wrong algorithm. Use MADS")
		else

			config = ConfigParameters()         
			set_kernel!(config, "kMaternARD5")  
			config.sc_type = SC_MAP
			config.n_iterations = PAMSO.func_eval-10
			config.force_jump = 10
			#config.n_init_samples = [0.0,0.0,0.0,0.0,1.0,0.0]
			lowerbound = PAMSO.lb; upperbound = PAMSO.ub
			optimizer, optimum = bayes_optimization(PAMSO.MBBF, lowerbound, upperbound, config)
			PAMSO.Param_best = optimizer
		end
	elseif(PAMSO.algo=="PSO")
		if("I" in PAMSO.input_types)
			println("Wrong algorithm. Use MADS")
		else
			o = Optim.Options(iterations = PAMSO.func_eval/15-1)
			res = optimize(PAMSO.MBBF,PAMSO.lb, PAMSO.ub, PAMSO.init, ParticleSwarm(;lower,upper,n_particles = 15),o)
			PAMSO.Param_best = Optim.minimizer(res)
		end
	else
		println("Error")
	end
end

	
