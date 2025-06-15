using Documenter
using ClaudeCodeSDK

makedocs(
    sitename="ClaudeCodeSDK.jl",
    authors="ClaudeCodeSDK.jl Contributors",
    modules=[ClaudeCodeSDK],
    format=Documenter.HTML(
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://your-organization.github.io/ClaudeCodeSDK.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Getting Started" => "getting-started.md",
        "API Reference" => "api.md",
        "Examples" => "examples.md",
        "Architecture" => "architecture.md",
        "Error Handling" => "errors.md",
    ],
    repo="https://github.com/your-organization/ClaudeCodeSDK.jl/blob/{commit}{path}#{line}",
    checkdocs=:exports,
)

deploydocs(
    repo="github.com/your-organization/ClaudeCodeSDK.jl.git",
    devbranch="main",
)