root = pwd()
using PAMSO
include(joinpath(root,"Gen_expansion","high_level_model.jl"))
include(joinpath(root,"Gen_expansion","low_level_model.jl"))
PAMSO_toy = PAMSO_block(gen_highlevel, gen_lowlevel, "MADS", 2, ["R","R"],[0.0,0.0],[10.0,1000.0],[1.0,1.0],300)
run(PAMSO_toy)
PAMSO_toy.MBBF(PAMSO_toy.Param_best)