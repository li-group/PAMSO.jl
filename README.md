# PAMSO

This package provides code to implement Parametric Autotuning Multi-time Scale Optimization Algorithm (PAMSO), an algorithm to solve multi-time scale optimization models. The algorithm has been published in the paper ...

## Table of Contents
1. [Overview](#overview)
2. [Installation](#requirements)
3. [Example](#running)
4. [Citation](#citation)


## [Overview](#overview)
Multi-time scale optimization models involving decision variables in multiple time scales have been used in different fields. To address scalability challenges in existing algorithms, we present the Parametric Autotuning Multi-time Scale Optimization algorithm (PAMSO) as a solution. PAMSO involves tuning parameters in a low-fidelity optimization model to help solve a higher-fidelity multi-time scale optimization model.  The tunable parameters represent the mismatch between the low-fidelity and high-fidelity models and are tuned by forming a black box with these models which is optimized using Derivative-Free Optimization methods. 

## [Installation](#requirements)
To intall the package and its dependencies run the following in julia
  ```julia
  using Pkg
  Pkg.add(url =)
  ```
  In addition, follow the instructions on [Gurobi.jl](https://github.com/jump-dev/Gurobi.jl) to install the solver Gurobi.

## [Example](#running)
As an example, we try to solve a generator planning problem. The problem is based on example 6.5 in the Introduction to Linear Programming [book](https://books.google.com/books/about/Introduction_to_Linear_Optimization.html?id=GAFsQgAACAAJ&source=kp_book_description) by Dimitris Bertsimas and John N. Tsitsiklis. The data we use for the problem is in the    Generator_expansion subfolder in the examples folder. The following steps are followed:
1. A high-level model and low-level model are formulated based on the full-space model and coded into separate files as functions. The high-level model is an aggregated version of model where we aggregate the system for entire time period. The low-level model involves fixing the capacity of the generators in the full-space model. The high-level model is parametrized based on the physics of the model. The high-level model is coded as a function which takes the tunable parameters as a parameters to the function and gives the high-level decisions (like the capacity of the gnerators) as an output. In this example, we store the high-level decision as a dictionary. The low-level model takes in the high-level decisions as parameters and outputs the objective function 
2. We create a PAMSO_block and initialize it with the high-level function (gen_highlevel) and low-level function (gen_lowlevel) as well as the DFO Algorithm to be used (can be "MADS","Bayesopt" or "PSO"),number of parameters (dimmensions) ,input_types (can be integer ("I") or real ("R")),lower bounds of parameters (lb),upper bounds of parameters ub,initial set of parameters (init), and the number of function evaluations (func_eval). The code is as follows:
```julia
  PAMSO_toy = PAMSO.PAMSO_block(gen_highlevel, gen_lowlevel, "MADS", 2, ["R","R"],[0.0,0.0],[10.0,1000.0],[1.0,1.0],300)
```
##Test
3. We then run the DFO agorithms on the associated MBBF using the following code:
 
  ```julia
  PAMSO.run(PAMSO_toy)
  ```
PAMSO_toy.Param_best holds the best set of parameters after training the parameters using the DFO solvers.

The solution can be compared to the solution from the full-space model. The full-space model is coded in the file full_space_model.jl. Camerin Lee constributed to coding the full space model and data for the example.

## [Citation](#citation)
Cite us 
