root = pwd()
include(joinpath(root,"high_level_model.jl"))
include(joinpath(root,"low_level_model.jl"))
using PAMSO

PAMSO_5loc = PAMSO.PAMSO_block(gen_highlevel, gen_lowlevel, "MADS", 2, ["R","R"],[0.0,0.0],[1.0,1.0],[1.0,1.0],2)
PAMSO.run(PAMSO_5loc)