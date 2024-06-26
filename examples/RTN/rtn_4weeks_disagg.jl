#include("data_utils.jl")
include("data_utils.jl")
include("rtn_model_gp2.jl")
include("rtn_agg_gp2.jl")
import XLSX
import CSV
using DataFrames
using Dates
#RTN_model= RTN(data, "baron")
#opt = RTN_model.solve_model()


root = pwd()
function func_all(x)
    x = round.(x,digits = 6)
    file = joinpath(root,"data", "case_7_daysn_3.xlsx")
    #xf = XLSX.readxlsx(joinpath(root,"data", "case_7_daysn.xlsx"))
    task = DataFrame(XLSX.readtable(file,"Tasks"))
    resources = DataFrame(XLSX.readtable(file,"Resources"))
    network = DataFrame(XLSX.readtable(file,"Network"))
    supply = []
    weeks = 4
    for i in range(1,weeks)
        sp = DataFrame(XLSX.readtable(file,"Supply_"*string(i)))
        push!(supply,sp)
    end
    days = 7*weeks
    num_day_week = 7
    horizon = days*24
    data = create_model_data(task, resources, network, supply, horizon,days,num_day_week)
    

    
    param_n = x[1]
    param_dof = x[2]
    param_dop = x[3]
    param_doi = x[4]
    param_b1 = x[5]
    param_x = x[6]
    RTN_agg_model = RTN_agg(data)
    opt,V_max,X_max = solve_model_agg(RTN_agg_model,param_n,param_dof,param_dop, param_doi,param_b1,param_x)
    opt_val = 0
    for i in 1:weeks
        task = DataFrame(XLSX.readtable(file,"Tasks"))
        resources = DataFrame(XLSX.readtable(file,"Resources"))
        network = DataFrame(XLSX.readtable(file,"Network"))
        supply = []
        sp = DataFrame(XLSX.readtable(file,"Supply_"*string(i)))
        push!(supply,sp)
        days = 7
        num_day_week = 7
        horizon = days*24
        data = create_model_data(task, resources, network, supply, horizon,days,num_day_week)
        RTN_model= RTN(data)
        opt = solve_model_full(RTN_model,V_max,X_max,"disagg_results_week_"*string(i)*".xlsx")
        #opt = solve_model_full(RTN_model,V_max,X_max)
        #opt = solve_model_full(RTN_model)
        opt_val = opt_val+opt
    end
    
    outp = DataFrame(A = opt_val/weeks,B = x[1],C = x[2],D = x[3],E = x[4],F = x[5],G = x[6],H = Dates.format(now(), "e: dd u yy, HH.MM.SS"))
    CSV.write("disagg_4weeks.csv",outp,append = true)
    
    
    # Create DataFrame
    return opt_val/weeks
end
#func_all([12.5729283524918,24.9040624741481,10.207448963089,9.88462285976198,30,0.195486020671371])
#func_all([0,20 ,30 ,30 ,30])
#func_all([0.0,0.0,0.0,0.0,20.0,0.0])
#func_all([5 ,10 ,1.24,10,10,8.7])
#func_all([0.008,20.15,22.00102,24.8027,30,0.69759])
#func_all([11,14.5,16.9,29,30,0.3])
#func_all([32.51323431   29.44815548 5.613563269 18.06288193 21.90463559 6.468374399])
#func_all([32.5132343093919, 29.4481554756186, 5.61356326922203,18.06288193421,21.9046355926038,6.46837439915257])
#func_all([0,16.7,9.9,20 ,29.9,1.4])
#func_all([50 ,30 ,16.2871446 ,10.12715223,30,3.609763876])
func_all([33.1,18.6,9.5,14.2,29.6,0.3])
#=
outp = DataFrame(A = "NOMAD",B =  Dates.format(now(), "e: dd u yy, HH.MM.SS"))
CSV.write("disagg_4weeks.csv",outp,append = true)  
using NOMAD
function bb(x)
  f =  func_all(x)
 # c = 1 - x[1]
  success = true
  count_eval = true
  bb_outputs = [f]
  return (success, count_eval, bb_outputs)
end
p = NomadProblem(6, 1, ["OBJ"], bb,
                lower_bound=[0.0,0.0,0.0,0.0,0.0,0.0],
                upper_bound=[50.0,30.0,30.0,30.0,30.0,30.0],initial_mesh_size = [25.0,15.0,15.0,15.0,15.0,15.0])
p.options.display_degree = 2
p.options.sgtelib_model_max_eval = 150
p.options.max_bb_eval = 150
#p.options.SGTELIB_MODEL_DIVERSIFICATION = 0.5
#p.options.anisotropy_factor = 0.5
p.options.display_stats = ["BBE","BBO","ITER_NUM","OBJ","SOL","TIME","TOTAL_SGTE"]
result = solve(p, [0.0,0.0,0.0,0.0,1.0,0.0])

outp = DataFrame(A = "PSO",B =  Dates.format(now(), "e: dd u yy, HH.MM.SS"))
CSV.write("disagg_4weeks.csv",outp,append = true)


using Optim
lower = [0.0,0.0,0.0,0.0,0.0,0.0]
upper = [50.0,30.0,30.0,30.0,30.0,30.0]
initial_x =  [0.0,0.0,0.0,0.0,1.0,0.0]
o = Optim.Options(iterations = 11)
res = optimize(func_all,lower, upper, initial_x, ParticleSwarm(;lower,upper,n_particles = 15),o)
println(res)

outp = DataFrame(A = "Bayesopt",B =  Dates.format(now(), "e: dd u yy, HH.MM.SS"))
CSV.write("disagg_4weeks.csv",outp,append = true)


using BayesOpt
config = ConfigParameters()         
set_kernel!(config, "kMaternARD5")  
config.sc_type = SC_MAP
config.n_iterations = 150
config.force_jump = 10
#config.n_init_samples = [0.0,0.0,0.0,0.0,1.0,0.0]
lowerbound = [0.0,0.0,0.0,0.0,0.0,0.0]; upperbound = [50.0,30.0,30.0,30.0,30.0,30.0]
optimizer, optimum = bayes_optimization(func_all, lowerbound, upperbound, config)
