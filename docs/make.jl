using Pkg
Pkg.activate(".")
Pkg.instantiate()


using Documenter
using PAMSO


makedocs(
    sitename = "PAMSO: Parametric Autotuning Multi-time Scale Optimization Algorithm",
    modules = [PAMSO],
    format = Documenter.HTML(),
    pages = ["Home" => "index.md",
           "PAMSO Elements" => "func_struct.md",
           "Cases" => "case.md"
          ]
)


