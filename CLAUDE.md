# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Description

This is a Julia port of the Claude Code SDK, providing a native Julia interface for interacting with Claude Code CLI. The implementation closely mirrors the Python SDK architecture while following Julia conventions and patterns.

**Status**: Core functionality complete and working. Basic queries and options handling fully functional with the Claude CLI.

## Prerequisites

- Julia 1.10+
- Node.js to install Claude Code CLI: `npm install -g @anthropic-ai/claude-code`

## Development Commands

### Installation
```bash
# Install dependencies
julia --project -e "using Pkg; Pkg.instantiate()"
```

### Testing
```bash
# Run all tests
julia --project -e "using Pkg; Pkg.test()"

# Run tests with verbose output
julia --project -e "using Pkg; Pkg.test(; test_args=[\"-v\"])"
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

## Architecture

This is a Julia SDK for Claude Code that wraps the `claude` CLI. The architecture follows a modular design closely matching the Python SDK:

### Core Components

- **Main Module** (`src/ClaudeCodeSDK.jl`): Entry point with the `query()` function and `InternalClient`
- **Types** (`src/types.jl`): Comprehensive type system matching Python SDK:
  - `ClaudeCodeOptions` with all 14 configuration fields
  - Message types (`AssistantMessage`, `UserMessage`, `SystemMessage`, `ResultMessage`)
  - Content blocks (`TextBlock`, `ToolUseBlock`, `ToolResultBlock`)
  - Tool definitions (`ReadTool`, `WriteTool`, `BashTool`)
- **Transport Layer** (`src/internal/cli.jl`): `SubprocessCLITransport` for CLI communication
- **Error Handling** (`src/errors.jl`): Exception hierarchy (`CLINotFoundError`, `CLIConnectionError`, etc.)
- **Tool System** (`src/internal/tools.jl`): Tool creation and execution functionality
- **Utilities** (`src/internal/utils.jl`): JSON conversion and helper functions

### Key Design Patterns

- **Vector-based Message Return**: `query()` returns `Vector{Message}` for easy iteration
- **Type Safety**: Full Julia type annotations with proper `struct` definitions
- **Transport Abstraction**: `SubprocessCLITransport` handles CLI process management
- **Message Parsing**: CLI text output parsed into typed `Message` objects
- **Tool Integration**: Local tool execution system for Read/Write/Bash operations

### API Reference

**Main Function:**
- `query(prompt::String; options::Union{ClaudeCodeOptions, Nothing}=nothing)` - Returns `Vector{Message}` for easy iteration

**Dependencies:**
- **Claude CLI**: `npm install -g @anthropic-ai/claude-code` (command: `claude`)
- **JSON.jl**: For data serialization and parsing
- **HTTP.jl**: Included for potential future API communication
- **Test.jl**: For testing framework (test dependency only)

### Current Status & Functionality

✅ **Working Features:**
- Basic Claude queries with text responses
- Configuration options (`ClaudeCodeOptions`)
- CLI process management and communication
- Message type system and parsing
- Error handling and proper exceptions
- Tool type definitions and local execution

⚠️ **Known Limitations:**
- Tool usage with Claude CLI needs CLI interface refinement
- Streaming JSON responses not yet implemented
- Some advanced Claude CLI options not yet supported

### Testing Strategy

Tests are structured with CLI availability detection:
- **Type Construction Tests**: Always run, test SDK components
- **CLI-dependent Tests**: Only run if `claude` CLI is available
- **Tool Tests**: Test local tool execution without CLI
- **Error Handling Tests**: Test proper exception behavior

## Implementation Notes

### Code Style
- All comments and docstrings in English for consistency
- Julia naming conventions: `snake_case` for functions, `PascalCase` for types
- Comprehensive type annotations throughout

### Architecture Decisions
- **Error Hierarchy**: Custom exceptions inherit from `Exception` (not abstract type)
- **CLI Communication**: Uses `claude --print` for non-interactive text output
- **Message Parsing**: Text responses wrapped in `AssistantMessage` with `TextBlock`
- **Tool System**: Local execution for development/testing, CLI integration for production use

### Performance Considerations
- Synchronous CLI process execution (suitable for most use cases)
- Message parsing optimized for typical Claude response sizes
- Memory-efficient handling of CLI output

## Quick Start Example

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

## Configuration Options Example

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

## Error Handling Example

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