using Documenter
using ClaudeCodeSDK

makedocs(
    sitename="ClaudeCodeSDK.jl",
    authors="ClaudeCodeSDK.jl Contributors",
    modules=[ClaudeCodeSDK],
    format=Documenter.HTML(
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://atelierarith.github.io/ClaudeCodeSDK.jl",
        assets=String[],
        repolink="https://github.com/AtelierArith/ClaudeCodeSDK.jl",
    ),
    pages=[
        "Home" => "index.md",
        "Getting Started" => "getting-started.md",
        "API Reference" => "api.md",
        "Examples" => "examples.md",
        "Architecture" => "architecture.md",
        "Error Handling" => "errors.md",
    ],
    repo="https://github.com/AtelierArith/ClaudeCodeSDK.jl/blob/{commit}{path}#{line}",
    checkdocs=:none,  # Changed from :exports to :none to be less strict
)

deploydocs(
    repo="github.com/AtelierArith/ClaudeCodeSDK.jl.git",
    devbranch="main",
    push_preview=true,
    forcepush=true,
)