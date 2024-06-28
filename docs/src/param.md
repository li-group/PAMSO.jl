# Tunable Parameters

In order to modify the intial values,lower bounds, upper bound or nature of the tunable parameters, the following functions can be used:


| Function       | Description                                           | Inputs                                                                                                                                   |
| -------------- | ----------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| set_initparams | Modify the initial parameters used by the DFO solvers | PAMSO problem block, vector of numbers with dimension as that of the parameters                                                          |
| set_lb         | Modify the upper bound of parameters                  | PAMSO problem block, vector of numbers with dimension as that of the parameters                                                          |
| set_ub         | Modify the lower bound of parameters                  | PAMSO problem block, vector of numbers with dimension as that of the parameters                                                          |
| set_inputtype  | Modify the input type of parameters                   | PAMSO problem block, vector of "R" (real) and "I"  (Integer) corresponding to each parameter (with dimension as that of the parameters) |

