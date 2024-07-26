# Block for Tunable Parameters

The PAMSO\_params is a structure which has the following fields

| Field Name  | Description                                                          |
| ----------- | -------------------------------------------------------------------- |
| init        | Vector of initial parameters for running the DFO algorithms          |
| lb          | Vector of lower bound of parameters                                  |
| ub          | Vector of upper bound of parameters                                  |
| input\_types | Vector of nature of parameters with "R" for real and "I" for integer |

In order to modify the intial values,lower bounds, upper bound or nature of the tunable parameters, the following functions can be used:


| Function       | Description                                           | Inputs                                                                                                                                   |
| -------------- | ----------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| set\_initparams | Modify the initial parameters used by the DFO solvers | PAMSO problem block, vector of numbers with dimension as that of the parameters                                                          |
| set\_lb         | Modify the upper bound of parameters                  | PAMSO problem block, vector of numbers with dimension as that of the parameters                                                          |
| set\_ub         | Modify the lower bound of parameters                  | PAMSO problem block, vector of numbers with dimension as that of the parameters                                                          |
| set\_inputtype  | Modify the input type of parameters                   | PAMSO problem block, vector of "R" (real) and "I"  (Integer) corresponding to each parameter (with dimension as that of the parameters) |

# PAMSO Block

The PAMSO\_block is a structure which has the following fields

| Field Name        | Description                                                                                                                                                            |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| high\_level\_model  | Function to generate the high-level model taking the vector of tunable parameters as input and returning the high-level decisions                                      |
| low\_level\_model   | Function to generate the low-level model taking the high-level decisions as input and returning the corresponding objective of the multi-time scale optimization model |
| full\_space\_model  | JuMP model for the full-space problem                                                                                                                                  |
| MBBF              | Multi-time scale black  box function connecting the high-level and low-level model                                                                                     |
| dimmensions       | Number of tunable parameters                                                                                                                                           |
| param             | PAMSO\_param block                                                                                                                                                      |
| Param\_best        | Best set of parameters after running the DFO algorithm       

We initialize the high\_level\_model, low\_level\_model, full\_space\_model, dimmensions and param. MBBF is automatically created and Param\_best is obtained after running the DFO solvers.

We have the following functions in the PAMSO package based on the PAMSO block.

| Function    | Description                                                                           | Inputs                                                                                           |
| ----------- | --------------------------------------------------------------------------------------| ------------------------------------------------------------------------------------------------ |
| set\_hlmodel | Modify the function for the high-level model                                          | PAMSO problem block, function                                                                    |
| set\_llmodel | Modify the function for the low-level model                                           | PAMSO problem block, function                                                                    |
| set\_fsmodel | Modify the full-space model                                                           | PAMSO problem block, optimization model                                                          |
| set\_MBBF    | Modify the MBBF. Call this function after modifying the high-level or low-level model | PAMSO problem block                                                                              |
| gen\_problem | Generate a PAMSO instance in the example folders                                      | Name of the instance                                                                             |
| run         | Run the PAMSO algorithm on a PAMSO problem block                                      | PAMSO problem block,DFO Solver ("MADS","Bayesopt","PSO"), maximum number of function evaluations (approximate) |


[Back to Home](index.md)
