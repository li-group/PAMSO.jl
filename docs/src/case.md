# Running different cases
In order to run an existing example, you can use the following lines of code

```julia
  PAMSO_problem = PAMSO.gen_problem(case)
  PAMSO.run(PAMSO_problem,algo,func_eval)	
```
Here case is a string represnting the case study, algo is the algorithm which can be "MADS","Bayesopt" or "PSO" and func_eval is the maximum number of function evaluations (approximately). Note that, Bayesopt and PSO does not accept integer parameters.
The list of cases is in the next section
# Cases

| Case                              | Description                                                                                                                                                  | Number of parameters |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------- |
| Generator_expansion               | Generator expansion for a day with 2 generators.                                                                                                             | 3                    |
| RTN: 1 week                       | Integrated design and scheduling in an RTN for 1 representative week                                                                                         | 6                    |
| RTN: 4 week (disaggregated)       | Integrated design and scheduling in an RTN for 4 representative weeks with a high-level model formulated based on explicitly having the demand for each week | 6                    |
| RTN: 4 week (aggregated)          | Integrated design and scheduling in an RTN for 4 representative weeks with a high-level model formulated based on the average of daily demand for the weeks  | 6                    |
| Connected microgrid: 5 locations  | Integrated planning and scheduling for 5 location microgrid connected to external sources of power                                                           | 2                    |
| Connected microgrid: 20 locations | Integrated planning and scheduling for 20 location microgrid connected to external sources of power                                                          | 2                    |
| Connected network: 200 locations   | Integrated planning and scheduling for 200 location network connected to external sources of power                                                           | 2                    |
| Isolated microgrid: 20 locations  | Integrated planning and scheduling for 20 location isolated microgrid                                                                                        | 2                    |

Note: The integrated planning and scheduling full-space models are approximate due to lack of beforehand knowledge of the number of power lines. Hence we bundle them in size of 20.

[Back to Home](index.md)
