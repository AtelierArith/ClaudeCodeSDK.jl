# Getting Started

This guide will help you get up and running with ClaudeCodeSDK.jl.

## Prerequisites

Before using ClaudeCodeSDK.jl, ensure you have:

- **Julia 1.10+** installed on your system
- **Node.js** for installing the Claude Code CLI
- **Claude Code CLI**: Install with `npm install -g @anthropic-ai/claude-code`

## Installation

Since the package is in development, you'll need to clone and set it up locally:

```bash
# Clone the repository
git clone <repository-url>
cd ClaudeCodeSDK.jl

# Install dependencies
julia --project -e "using Pkg; Pkg.instantiate()"
```

## Basic Usage

### Simple Query

```julia
using ClaudeCodeSDK

# Basic query - returns Vector{Message}
result = query("Hello Claude")
for message in result
    if message isa AssistantMessage
        for block in message.content
            if block isa TextBlock
                println(block.text)
            end
        end
    end
end
```

### Using Configuration Options

```julia
using ClaudeCodeSDK

# Configure options
options = ClaudeCodeOptions(
    system_prompt="You are a helpful assistant",
    max_turns=1
)

# Query with options
result = query("Tell me a joke", options=options)
for message in result
    if message isa AssistantMessage
        for block in message.content
            if block isa TextBlock
                println(block.text)
            end
        end
    end
end
```

### Complete Configuration Example

```julia
# All available configuration options
options = ClaudeCodeOptions(
    system_prompt="You are a helpful assistant",
    max_turns=5,
    cwd="/path/to/project",
    allowed_tools=["Read", "Write", "Bash"],
    permission_mode="acceptEdits",
    model="claude-3-5-sonnet-20241022",
    enable_mcp=false,
    mcp_server_configs=nothing,
    suppress_client_logs=true,
    custom_instructions=nothing,
    memory_path=nothing,
    memory_disabled=false,
    test_mode=false,
    disable_tools=String[]
)

result = query("Help me with my project", options=options)
```

## Running Tests

```bash
# Run all tests
julia --project -e "using Pkg; Pkg.test()"

# Run tests with verbose output
julia --project -e "using Pkg; Pkg.test(; test_args=[\"-v\"])"
```

## Running Examples

The repository includes several example files:

```bash
# Start Julia REPL with project
julia --project

# Run specific examples
julia --project examples/quick_start.jl
julia --project examples/tool_execution_demo.jl
julia --project examples/cli_aware_demo.jl
```

## Error Handling

Always wrap your queries in try-catch blocks for robust error handling:

```julia
using ClaudeCodeSDK

try
    result = query("Hello")
    for message in result
        println(message)
    end
catch e
    if e isa CLINotFoundError
        println("Please install Claude Code CLI: npm install -g @anthropic-ai/claude-code")
    elseif e isa ProcessError
        println("Process failed with exit code: $(e.exit_code)")
    elseif e isa CLIJSONDecodeError
        println("Failed to parse response: $e")
    else
        println("Unexpected error: $e")
    end
end
```

## Next Steps

- Check out the [API Reference](api.md) for detailed function documentation
- Explore [Examples](examples.md) for more usage patterns
- Learn about the [Architecture](architecture.md) to understand the internal design