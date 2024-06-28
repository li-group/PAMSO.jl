using Documenter
using PAMSO

makedocs(
    sitename = "PAMSO: Parametric Autotuning Multi-time Scale Optimization Algorithm",
    modules = [PAMSO],
    format = Documenter.HTML(prettyurls = true),
    pages = ["Home" => "index.md",
           "Parameters" => "param.md",
           "Cases" => "case.md"
          ]
)


