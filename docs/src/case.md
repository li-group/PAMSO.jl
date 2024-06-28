# Running different cases
In order to run an existing example, you can use the following lines of code

```julia
  PAMSO_problem = PAMSO.gen_problem(case)
  PAMSO.run(PAMSO_problem,algo,func_eval)	
```
Here case is a string represnting the case study, algo is the algorithm which can be "MADS","Bayesopt" or "PSO" and func_eval is the maximum number of function evaluations. Note that, Bayesopt and PSO does not accept integer parameters.
The list of cases is in the next section
# Cases

| Case                | Description                                      |
| ------------------- | ------------------------------------------------ |
| Generator_expansion | Generator expansion for a day with 2 generators  |
