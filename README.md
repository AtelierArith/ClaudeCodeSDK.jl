# ClaudeCodeSDK.jl

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/AtelierArith/ClaudeCodeSDK.jl)

[![CI](https://github.com/AtelierArith/ClaudeCodeSDK.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/AtelierArith/ClaudeCodeSDK.jl/actions/workflows/ci.yml)

[![Documentation](https://github.com/AtelierArith/ClaudeCodeSDK.jl/actions/workflows/documentation.yml/badge.svg)](https://github.com/AtelierArith/ClaudeCodeSDK.jl/actions/workflows/documentation.yml)

## Warning

This implementation is UNOFFICIAL!!!

## Description

A comprehensive Julia port of the Claude Code SDK that provides a native Julia interface for interacting with Claude Code CLI. This implementation closely mirrors the official Python SDK architecture while leveraging Julia's strengths in type safety and performance.

**Status**: ✅ **Fully functional** - All core features implemented and tested. Complete compatibility with Claude Code CLI including tools, MCP servers, and advanced configuration options.

## Installation

This package is currently in development. To use it:

```bash
# Clone the repository
git clone https://github.com/AtelierArith/ClaudeCodeSDK.jl.git
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

# Basic query (new keyword argument API)
for message in query(prompt="What is 2 + 2?")
    if message isa AssistantMessage
        for block in message.content
            if block isa TextBlock
                println(block.text)  # Output: 4
            end
        end
    end
end

# With configuration options
options = ClaudeCodeOptions(
    system_prompt="You are a helpful assistant that explains things simply.",
    max_turns=1
)

for message in query(prompt="Explain what Julia is in one sentence.", options=options)
    if message isa AssistantMessage
        for block in message.content
            if block isa TextBlock
                println(block.text)
            end
        end
    end
end

# Using tools
options = ClaudeCodeOptions(
    allowed_tools=["Read", "Write"],
    permission_mode="acceptEdits"
)

for message in query(
    prompt="Create a file called hello.txt with 'Hello, World!' in it",
    options=options
)
    if message isa AssistantMessage
        for block in message.content
            if block isa TextBlock
                println(block.text)
            end
        end
    elseif message isa ResultMessage
        println("Cost: \$$(round(message.cost_usd, digits=4))")
    end
end
```

## Development Commands

### Testing
```bash
# Run all tests (288 tests total)
julia --project -e "using Pkg; Pkg.test()"

# Run specific test files
julia --project test/test_types.jl
julia --project test/test_errors.jl
julia --project test/test_client.jl
julia --project test/test_transport.jl
julia --project test/test_integration.jl
```

### Running Examples
```bash
# Start Julia REPL with project
julia --project

# Run example files
julia --project examples/quick_start.jl
julia --project examples/streaming_demo.jl
julia --project examples/tool_execution_demo.jl
julia --project examples/cli_aware_demo.jl
```

## Usage

### Basic Query

```julia
using ClaudeCodeSDK

# Simple query - returns Vector{Message}
result = query(prompt="Hello Claude")
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

result = query(prompt="Help me with my project", options=options)
```

### Features

✅ **Fully Implemented:**
- **Complete CLI Integration**: All Claude Code CLI options supported
- **Keyword Argument API**: `query(prompt="...", options=...)` matching Python SDK
- **Advanced Configuration**: MCP servers, tool management, permission modes
- **Robust Error Handling**: Comprehensive exception hierarchy
- **Type Safety**: Full Julia type annotations throughout
- **Tool Execution**: Read, Write, Bash tools with proper result handling
- **Message Parsing**: Complete support for all message types
- **JSON Streaming**: Real-time response parsing from CLI
- **Environment Management**: Working directory and environment variable support
- **Cost Tracking**: Usage and cost information from queries

✅ **Python SDK Compatibility:**
- Same API patterns and functionality
- Equivalent configuration options
- Matching error handling
- Similar message structure
- **Complete test suite ported** (288 tests matching Python SDK exactly)

## API Reference

### `query(; prompt::String, options::Union{ClaudeCodeOptions, Nothing}=nothing)`

Main function for querying Claude Code.

**Parameters:**
- `prompt::String`: The prompt to send to Claude
- `options::Union{ClaudeCodeOptions, Nothing}`: Optional configuration (defaults to ClaudeCodeOptions() if nothing)
  - Set `options.permission_mode` to control tool execution:
    - `"default"`: CLI prompts for dangerous tools
    - `"acceptEdits"`: Auto-accept file edits
    - `"bypassPermissions"`: Allow all tools (use with caution)
  - Set `options.cwd` for working directory

**Returns:** `Vector{Message}` - Vector of messages from the conversation

**Example:**
```julia
# Simple usage
for message in query(prompt="Hello")
    println(message)
end

# With options
for message in query(
    prompt="Hello",
    options=ClaudeCodeOptions(
        system_prompt="You are helpful",
        cwd=homedir()
    )
)
    println(message)
end
```

### Types

See [src/types.jl](src/types.jl) for complete type definitions:
- `ClaudeCodeOptions` - Configuration options with 14 fields including MCP support
- `McpServerConfig` - MCP server configuration structure
- `AssistantMessage`, `UserMessage`, `SystemMessage`, `ResultMessage` - Message types
- `TextBlock`, `ToolUseBlock`, `ToolResultBlock` - Content blocks
- `ReadTool`, `WriteTool`, `BashTool` - Tool definitions

### Error Types

- `ClaudeSDKError` - Base exception type
- `CLINotFoundError` - Claude CLI not installed
- `CLIConnectionError` - Connection issues
- `ProcessError` - CLI process failures
- `CLIJSONDecodeError` - Response parsing issues

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
    result = query(prompt="Hello")
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

**Comprehensive test suite with 288 tests total** - Complete port from Python SDK:

### Test Files Structure:
1. **`test/test_types.jl`** - Message types, options configuration, content blocks
2. **`test/test_errors.jl`** - Error hierarchy, exception handling, string representations
3. **`test/test_client.jl`** - Query function, message processing, client configuration
4. **`test/test_transport.jl`** - CLI discovery, command building, JSON streaming, process management
5. **`test/test_integration.jl`** - End-to-end testing, CLI integration, comprehensive scenarios

### Test Coverage:
- **Type Construction**: SDK component creation and validation
- **Message Types**: All message and content block types
- **Tool Functionality**: Tool creation and execution
- **CLI Integration**: Full end-to-end testing with actual CLI (when available)
- **Error Handling**: All exception types and scenarios
- **JSON Streaming**: CLI response parsing and message flow
- **Process Management**: Subprocess lifecycle and error handling

### Test Environment Handling:
Tests gracefully handle CLI availability:
- **Core tests** always run (types, errors, client logic)
- **CLI-dependent tests** only run when `claude` CLI is detected
- **Integration tests** provide both mocked and live CLI scenarios
- All 288 tests pass consistently ✅

## Examples

Multiple example files demonstrate different usage patterns:
- [examples/quick_start.jl](examples/quick_start.jl) - Basic usage
- [examples/streaming_demo.jl](examples/streaming_demo.jl) - JSON streaming capabilities
- [examples/tool_execution_demo.jl](examples/tool_execution_demo.jl) - Local tool execution
- [examples/cli_aware_demo.jl](examples/cli_aware_demo.jl) - CLI-aware functionality

## License

MIT
