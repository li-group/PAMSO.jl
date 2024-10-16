using PAMSO
using Test
using Random
using JuMP
Random.seed!(1)

@testset "PAMSO.jl" begin
    # Write your tests here.
    cd(dirname(pathof(PAMSO)))
    println(pwd())
    PAMSO_toy = PAMSO.gen_problem("Generator expansion")
    optimize!(PAMSO_toy.full_space_model)
    obj_actual = objective_value(PAMSO_toy.full_space_model)
    PAMSO.run(PAMSO_toy,"MADS",300)
    @test isapprox(PAMSO_toy.MBBF(PAMSO_toy.Param_best), obj_actual,rtol = 0.01)
    PAMSO_toy = PAMSO.gen_problem("Generator expansion")
    PAMSO.run(PAMSO_toy,"Bayesopt",300)
    @test isapprox(PAMSO_toy.MBBF(PAMSO_toy.Param_best), obj_actual,rtol = 0.01)
    PAMSO_toy = PAMSO.gen_problem("Generator expansion")
    PAMSO.run(PAMSO_toy,"PSO",300)
    @test isapprox(PAMSO_toy.MBBF(PAMSO_toy.Param_best), obj_actual,rtol = 0.01)
    
end
