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
    allowed_tools=["Read", "Write", "Bash"],
    max_thinking_tokens=8000,
    system_prompt="You are a helpful assistant",
    append_system_prompt=nothing,
    mcp_tools=String[],
    mcp_servers=Dict{String, McpServerConfig}(),
    permission_mode="acceptEdits",
    continue_conversation=false,
    resume=nothing,
    max_turns=5,
    disallowed_tools=String[],
    model="claude-3-5-sonnet-20241022",
    permission_prompt_tool_name=nothing,
    cwd="/path/to/project"
)

result = query("Help me with my project", options=options)
```

## Running Tests

The SDK includes a comprehensive test suite with 288 tests ported from the Python SDK:

```bash
# Run all tests (288 tests total)
julia --project -e "using Pkg; Pkg.test()"

# Run specific test files
julia --project test/test_types.jl        # Message types and options
julia --project test/test_errors.jl       # Error handling
julia --project test/test_client.jl       # Client functionality  
julia --project test/test_transport.jl    # CLI communication
julia --project test/test_integration.jl  # End-to-end scenarios

# Run tests with verbose output
julia --project -e "using Pkg; Pkg.test(; test_args=[\"-v\"])"
```

### Test Features:
- **Complete Python SDK compatibility** - All test patterns preserved
- **CLI adaptive** - Tests detect CLI availability automatically
- **Environment friendly** - Core tests run without CLI dependency
- **100% pass rate** - All 288 tests consistently pass ✅

## Running Examples

The repository includes several example files:

```bash
# Start Julia REPL with project
julia --project

# Run specific examples
julia --project examples/quick_start.jl
julia --project examples/streaming_demo.jl    # NEW: JSON streaming demo
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