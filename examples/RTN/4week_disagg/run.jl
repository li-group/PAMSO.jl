root = pwd()
include(joinpath(root,"high_level_model.jl"))
include(joinpath(root,"low_level_model.jl"))
import PAMSO
PAMSO_RTN = PAMSO.PAMSO_block(gen_highlevel, gen_lowlevel, "MADS", 6, ["R","R","R","R","R","R"],[0.0,0.0,0.0,0.0,0.0,0.0],[50.0,30.0,30.0,30.0,30.0,30.0],[0.0,0.0,0.0,0.0,1.0,0.0],1)
PAMSO.run(PAMSO_RTN)