using PAMSO
using Test
using Random
Random.seed!(1)
@testset "PAMSO.jl" begin
    # Write your tests here.
    root = pwd()
    cd(joinpath(root,"examples","Gen_expanison"))
    include("full_space_model.jl")
    include("high_level_model.jl")
    include("low_level_model.jl")
    PAMSO_toy = PAMSO.PAMSO_block(gen_highlevel, gen_lowlevel, "MADS", 2, ["R","R"],[0.0,0.0],[10.0,100.0],[1.0,1.0],300)
    PAMSO.run(PAMSO_toy)
    @test isapprox(PAMSO_toy.MBBF(PAMSO_toy.Param_best), 167415.4166,rtol = 0.01)
    PAMSO_toy = PAMSO.PAMSO_block(gen_highlevel, gen_lowlevel, "Bayesopt", 2, ["R","R"],[0.0,0.0],[10.0,100.0],[1.0,1.0],300)
	PAMSO.run(PAMSO_toy)
    @test isapprox(PAMSO_toy.MBBF(PAMSO_toy.Param_best), 167415.4166,rtol = 0.01)
    PAMSO_toy = PAMSO.PAMSO_block(gen_highlevel, gen_lowlevel, "PSO", 2, ["R","R"],[0.0,0.0],[10.0,100.0],[1.0,1.0],300)
	PAMSO.run(PAMSO_toy)
    @test isapprox(PAMSO_toy.MBBF(PAMSO_toy.Param_best), 167415.4166,rtol = 0.01)
end
