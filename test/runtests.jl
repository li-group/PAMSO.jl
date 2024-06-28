using PAMSO
using Test
using Random
Random.seed!(1)
@testset "PAMSO.jl" begin
    # Write your tests here.
    include("full_space_model.jl")
    include("high_level_model.jl")
    include("low_level_model.jl")
    PAMSO_toy = PAMSO.PAMSO_block(gen_highlevel, gen_lowlevel, "MADS", 3, ["R","R","R"],[0.0,0.0,0.0],[10.0,10.0,100.0],[1.0,1.0,1.0],300)
    PAMSO.run(PAMSO_toy)
    @test isapprox(PAMSO_toy.MBBF(PAMSO_toy.Param_best), obj_actual,rtol = 0.01)
    PAMSO_toy = PAMSO.PAMSO_block(gen_highlevel, gen_lowlevel, "Bayesopt", 3, ["R","R","R"],[0.0,0.0,0.0],[10.0,10.0,100.0],[1.0,1.0,1.0],300)
	PAMSO.run(PAMSO_toy)
    @test isapprox(PAMSO_toy.MBBF(PAMSO_toy.Param_best), obj_actual,rtol = 0.01)
    PAMSO_toy = PAMSO.PAMSO_block(gen_highlevel, gen_lowlevel, "PSO", 3, ["R","R","R"],[0.0,0.0,0.0],[10.0,10.0,100.0],[1.0,1.0,1.0],300)
	PAMSO.run(PAMSO_toy)
    @test isapprox(PAMSO_toy.MBBF(PAMSO_toy.Param_best), obj_actual,rtol = 0.01)
end
