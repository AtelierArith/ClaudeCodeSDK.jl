# Architecture

This document describes the internal architecture of ClaudeCodeSDK.jl and how it mirrors the Python SDK while following Julia conventions.

## Overview

ClaudeCodeSDK.jl is a Julia port of the Claude Code SDK that wraps the Claude Code CLI. The architecture follows a modular design closely matching the Python SDK while leveraging Julia's type system and conventions.

## Core Components

### 1. Main Module (`src/ClaudeCodeSDK.jl`)

The entry point containing:
- `query()` function - Main public API
- `InternalClient` - Core orchestration logic
- Module exports and public interface

```julia
# Main query function
function query(prompt::String; options::Union{ClaudeCodeOptions, Nothing}=nothing)
    client = InternalClient()
    return client.query(prompt, options)
end
```

### 2. Types System (`src/types.jl`)

Comprehensive type definitions that mirror the Python SDK:

#### Configuration Types
- `ClaudeCodeOptions` - Complete configuration with 14 fields including MCP support
- `McpServerConfig` - MCP server configuration structure
- Support for all Claude CLI options and parameters

#### Message Types
- `Message` (abstract base type)
- `AssistantMessage` - Claude's responses
- `UserMessage` - User inputs  
- `SystemMessage` - System prompts
- `ResultMessage` - Operation results

#### Content Block Types
- `ContentBlock` (abstract base type)
- `TextBlock` - Text content
- `ToolUseBlock` - Tool invocation requests
- `ToolResultBlock` - Tool execution results

#### Tool Types
- `Tool` (abstract base type)
- `ReadTool` - File reading operations
- `WriteTool` - File writing operations
- `BashTool` - Command execution

### 3. Transport Layer (`src/internal/cli.jl`)

Handles communication with the Claude CLI:

```julia
abstract type CLITransport end

struct SubprocessCLITransport <: CLITransport
    # CLI process management
end

function execute_query(transport::SubprocessCLITransport, prompt::String, options::ClaudeCodeOptions)
    # Execute CLI command and capture output
end
```

**Key responsibilities:**
- CLI process spawning and management
- Command-line argument construction
- Output capture and parsing
- Error handling and process cleanup

### 4. Error Handling (`src/errors.jl`)

Comprehensive exception hierarchy:

```julia
abstract type ClaudeSDKError <: Exception end

struct CLINotFoundError <: ClaudeSDKError
    message::String
end

struct CLIConnectionError <: ClaudeSDKError
    message::String
end

struct ProcessError <: ClaudeSDKError
    exit_code::Int
    output::String
end

struct CLIJSONDecodeError <: ClaudeSDKError
    message::String
    raw_output::String
end
```

### 5. Tool System (`src/internal/tools.jl`)

Local tool execution capabilities:

```julia
function execute_tool(tool::ReadTool)
    # Read file and return content
end

function execute_tool(tool::WriteTool)
    # Write content to file
end

function execute_tool(tool::BashTool)
    # Execute bash command
end
```

### 6. Utilities (`src/internal/utils.jl`)

Helper functions for:
- JSON serialization/deserialization
- CLI argument formatting
- Response parsing
- Type conversions

## Key Design Patterns

### Vector-based Message Return

Unlike the Python SDK's async streaming approach, the Julia SDK returns a `Vector{Message}`:

```julia
# Python SDK (async streaming)
async for message in query("hello"):
    print(message)

# Julia SDK (vector-based)
for message in query("hello")
    println(message)
end
```

**Benefits:**
- Simpler iteration pattern
- Better integration with Julia's ecosystem
- Easier debugging and inspection
- Natural fit for Julia's array-oriented design

### Type Safety

Full Julia type annotations with strict type checking:

```julia
struct ClaudeCodeOptions
    allowed_tools::Vector{String}
    max_thinking_tokens::Int
    system_prompt::Union{String, Nothing}
    append_system_prompt::Union{String, Nothing}
    mcp_tools::Vector{String}
    mcp_servers::Dict{String, McpServerConfig}
    permission_mode::Union{String, Nothing}
    continue_conversation::Bool
    resume::Union{String, Nothing}
    max_turns::Union{Int, Nothing}
    disallowed_tools::Vector{String}
    model::Union{String, Nothing}
    permission_prompt_tool_name::Union{String, Nothing}
    cwd::Union{String, Nothing}
end
```

### Transport Abstraction

Clean separation between CLI communication and SDK logic:

```julia
abstract type CLITransport end

# Allows for future implementations (HTTP, WebSocket, etc.)
struct SubprocessCLITransport <: CLITransport end
struct HTTPTransport <: CLITransport end  # Future possibility
```

### Message Parsing Strategy

The SDK handles CLI text output by:

1. **CLI Execution**: Run `claude --print` for text output
2. **Response Wrapping**: Wrap text in `AssistantMessage` with `TextBlock`
3. **Type Construction**: Create proper message hierarchy
4. **Vector Return**: Return as `Vector{Message}` for iteration

## Data Flow

```
User Query
    ↓
query() function
    ↓
InternalClient.query()
    ↓
SubprocessCLITransport.execute_query()
    ↓
CLI Process (`claude --print`)
    ↓
Raw Text Output
    ↓
Response Parsing
    ↓
Message Construction
    ↓
Vector{Message} Return
    ↓
User Iteration
```

## CLI Integration

### Command Construction

Options are converted to CLI arguments:

```julia
function build_cli_args(options::ClaudeCodeOptions)
    args = String[]
    
    # Add --print for text output
    push!(args, "--print")
    
    # Add configured options
    if options.system_prompt !== nothing
        push!(args, "--system-prompt", options.system_prompt)
    end
    
    if options.max_turns !== nothing
        push!(args, "--max-turns", string(options.max_turns))
    end
    
    if !isempty(options.allowed_tools)
        for tool in options.allowed_tools
            push!(args, "--allowed-tools", tool)
        end
    end
    
    # ... handle all other options
    
    return args
end
```

### Process Management

Safe process handling with proper cleanup:

```julia
function execute_cli_command(args::Vector{String}, input::String)
    try
        process = open(`claude $args`, "r+")
        write(process, input)
        close(process.in)
        output = read(process, String)
        wait(process)
        return output
    catch e
        # Handle process errors
        throw(ProcessError(e.exitcode, e.message))
    end
end
```

## Testing Strategy

### Multi-tier Testing Approach

1. **Type Construction Tests** (always run)
   - Test SDK components without CLI dependency
   - Validate type system and constructors
   - Unit test utilities and helpers

2. **CLI-dependent Tests** (conditional)
   - Only run if `claude` CLI is available
   - Test actual CLI communication
   - Integration testing with real Claude

3. **Tool Tests** (local execution)
   - Test tool system without CLI
   - Validate tool execution logic
   - File system operations

4. **Error Handling Tests**
   - Test exception hierarchy
   - Validate error propagation
   - CLI failure scenarios

### Test Detection Pattern

```julia
function is_cli_available()
    try
        run(`claude --version`)
        return true
    catch
        return false
    end
end

@testset "CLI Tests" begin
    if is_cli_available()
        # Run CLI-dependent tests
    else
        @test_skip "CLI not available"
    end
end
```

## Future Enhancements

### Planned Improvements

1. **Streaming Support**
   - Implement streaming JSON response parsing
   - Support real-time output display
   - Maintain backward compatibility

2. **Enhanced Tool Integration**
   - Better CLI tool interface
   - Tool result parsing improvements
   - Interactive tool approval

3. **Performance Optimizations**
   - CLI process reuse
   - Response caching
   - Parallel query support

4. **Advanced Features**
   - Memory persistence
   - Conversation threading
   - Plugin system

### Extensibility Points

The architecture supports future extensions:

- **New Transport Types**: HTTP, WebSocket, gRPC
- **Additional Tools**: Custom tool definitions
- **Message Formats**: JSON, XML, custom protocols
- **Authentication**: API keys, OAuth, custom auth

## Comparison with Python SDK

| Aspect | Python SDK | Julia SDK |
|--------|------------|-----------|
| **Return Type** | `AsyncIterator[Message]` | `Vector{Message}` |
| **Execution** | Async/await | Synchronous |
| **Type System** | Dataclasses + type hints | Native Julia structs |
| **Error Handling** | Exception hierarchy | Exception hierarchy |
| **CLI Communication** | Subprocess async | Subprocess sync |
| **Tool System** | Integrated | Local + CLI integration |
| **Dependencies** | aiofiles, subprocess | JSON.jl, Base modules |

The Julia implementation maintains API compatibility while leveraging Julia's strengths in type safety, performance, and ecosystem integration.