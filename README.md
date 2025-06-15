# ClaudeCodeSDK.jl

## Warning

This implementation is UNOFFICIAL!!!

## Description

A Julia port of the Claude Code SDK, providing a native Julia interface for interacting with Claude Code CLI. This implementation closely mirrors the Python SDK architecture while following Julia conventions and patterns.

**Status**: Core functionality complete and working. Basic queries and options handling fully functional with the Claude CLI.

## Installation

This package is currently in development. To use it:

```bash
# Clone the repository
git clone <repository-url>
cd ClaudeCodeSDK.jl

# Install dependencies
julia --project -e "using Pkg; Pkg.instantiate()"
```

**Prerequisites:**
- Julia 1.10+
- Node.js to install Claude Code CLI: `npm install -g @anthropic-ai/claude-code`

## Quick Start

```julia
using ClaudeCodeSDK

# Basic query
for message in query("What is 2 + 2?")
    if message isa AssistantMessage
        for block in message.content
            if block isa TextBlock
                println(block.text)
            end
        end
    end
end

# With options
options = ClaudeCodeOptions(
    system_prompt="You are a helpful assistant",
    max_turns=1
)
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

## Development Commands

### Testing
```bash
# Run all tests
julia --project -e "using Pkg; Pkg.test()"
```

### Running Examples
```bash
# Start Julia REPL with project
julia --project

# Run example files
julia --project examples/quick_start.jl
julia --project examples/tool_execution_demo.jl
julia --project examples/cli_aware_demo.jl
```

## Usage

### Basic Query

```julia
using ClaudeCodeSDK

# Simple query - returns Vector{Message}
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

### Configuration Options

```julia
# Complete options configuration
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

### Current Status & Limitations

✅ **Working Features:**
- Basic Claude queries with text responses
- Configuration options (`ClaudeCodeOptions`)
- CLI process management and communication
- Message type system and parsing
- Error handling with proper exceptions
- Tool type definitions and local execution

⚠️ **Known Limitations:**
- Tool usage with Claude CLI needs CLI interface refinement
- Streaming JSON responses not yet implemented
- Some advanced Claude CLI options not yet supported

## API Reference

### `query(prompt::String; options::Union{ClaudeCodeOptions, Nothing}=nothing)`

Main function for querying Claude.

**Parameters:**
- `prompt::String`: The prompt to send to Claude
- `options::Union{ClaudeCodeOptions, Nothing}`: Optional configuration

**Returns:** `Vector{Message}` - Vector of response messages for easy iteration

### Types

See [src/types.jl](src/types.jl) for complete type definitions:
- `ClaudeCodeOptions` - Configuration options with all 14 fields
- `AssistantMessage`, `UserMessage`, `SystemMessage`, `ResultMessage` - Message types
- `TextBlock`, `ToolUseBlock`, `ToolResultBlock` - Content blocks
- `ReadTool`, `WriteTool`, `BashTool` - Tool definitions

## Architecture

This Julia SDK follows a modular design with:

- **Main Module** (`src/ClaudeCodeSDK.jl`): Entry point with `query()` function and `InternalClient`
- **Transport Layer** (`src/internal/cli.jl`): `SubprocessCLITransport` for CLI communication
- **Error Handling** (`src/errors.jl`): Exception hierarchy (`CLINotFoundError`, `CLIConnectionError`, etc.)
- **Tool System** (`src/internal/tools.jl`): Tool creation and execution functionality

## Error Handling

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
    end
end
```

See [src/errors.jl](src/errors.jl) for the complete exception hierarchy.

## Testing Strategy

Tests are structured with CLI availability detection:
- **Type Construction Tests**: Always run, test SDK components
- **CLI-dependent Tests**: Only run if `claude` CLI is available
- **Tool Tests**: Test local tool execution without CLI
- **Error Handling Tests**: Test proper exception behavior

## Examples

Multiple example files demonstrate different usage patterns:
- [examples/quick_start.jl](examples/quick_start.jl) - Basic usage
- [examples/tool_execution_demo.jl](examples/tool_execution_demo.jl) - Local tool execution
- [examples/cli_aware_demo.jl](examples/cli_aware_demo.jl) - CLI-aware functionality

## License

MIT