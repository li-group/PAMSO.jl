# Block for Tunable Parameters

The PAMSO_params is a structure which has the following fields

| Field Name  | Description                                                          |
| ----------- | -------------------------------------------------------------------- |
| init        | Vector of initial parameters for running the DFO algorithms          |
| lb          | Vector of lower bound of parameters                                  |
| ub          | Vector of upper bound of parameters                                  |
| input_types | Vector of nature of parameters with "R" for real and "I" for integer |

In order to modify the intial values,lower bounds, upper bound or nature of the tunable parameters, the following functions can be used:


| Function       | Description                                           | Inputs                                                                                                                                   |
| -------------- | ----------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| set_initparams | Modify the initial parameters used by the DFO solvers | PAMSO problem block, vector of numbers with dimension as that of the parameters                                                          |
| set_lb         | Modify the upper bound of parameters                  | PAMSO problem block, vector of numbers with dimension as that of the parameters                                                          |
| set_ub         | Modify the lower bound of parameters                  | PAMSO problem block, vector of numbers with dimension as that of the parameters                                                          |
| set_inputtype  | Modify the input type of parameters                   | PAMSO problem block, vector of "R" (real) and "I"  (Integer) corresponding to each parameter (with dimension as that of the parameters) |

# PAMSO Block

The PAMSO_block is a structure which has the following fields

| Field Name        | Description                                                                                                                                                            |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| high_level_model  | Function to generate the high-level model taking the vector of tunable parameters as input and returning the high-level decisions                                      |
| low_level_model   | Function to generate the low-level model taking the high-level decisions as input and returning the corresponding objective of the multi-time scale optimization model |
| full_space_model  | JuMP model for the full-space problem                                                                                                                                  |
| MBBF              | Multi-time scale black  box function connecting the high-level and low-level model                                                                                     |
| dimmensions       | Number of tunable parameters                                                                                                                                           |
| param             | PAMSO_param block                                                                                                                                                      |
| Param_best        | Best set of parameters after running the DFO algorithm       

We initialize the high_level_model, low_level_model, full_space_model, dimmensions and param. MBBF is automatically created and Param_best is obtained after running the DFO solvers.

We have the following functions in the PAMSO package based on the PAMSO block.

| Function    | Description                                      | Inputs                                                                                           |
| ----------- | ------------------------------------------------ | ------------------------------------------------------------------------------------------------ |
| set_hlmodel | Modify the function for the high-level model     | PAMSO problem block, function                                                                    |
| set_llmodel | Modify the function for the low-level model      | PAMSO problem block, function                                                                    |
| set_fsmodel | Modify the full-space model                      | PAMSO problem block, optimization model                                                          |
| gen_problem | Generate a PAMSO instance in the example folders | Name of the instance                                                                             |
| run         | Run the PAMSO algorithm on a PAMSO problem block | PAMSO problem block,DFO Solver ("MADS","Bayesopt","PSO"), maximum number of function evaluations (approximate) |


[Back to Home](index.md)
