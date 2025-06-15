# API Reference

## Main Functions

```@docs
ClaudeCodeSDK.query
```

## Types

### Configuration

```@docs
ClaudeCodeSDK.ClaudeCodeOptions
```

### Messages

```@docs
ClaudeCodeSDK.Message
ClaudeCodeSDK.AssistantMessage
ClaudeCodeSDK.UserMessage
ClaudeCodeSDK.SystemMessage
ClaudeCodeSDK.ResultMessage
```

### Content Blocks

```@docs
ClaudeCodeSDK.TextBlock
ClaudeCodeSDK.ToolUseBlock
ClaudeCodeSDK.ToolResultBlock
```

### Tools

```@docs
ClaudeCodeSDK.Tool
ClaudeCodeSDK.ReadTool
ClaudeCodeSDK.WriteTool
ClaudeCodeSDK.BashTool
ClaudeCodeSDK.ToolResult
```

### Tool Functions

```@docs
ClaudeCodeSDK.create_tool_from_block
ClaudeCodeSDK.execute_tool
```

## Error Types

```@docs
ClaudeCodeSDK.ClaudeSDKError
ClaudeCodeSDK.CLINotFoundError
ClaudeCodeSDK.CLIConnectionError
ClaudeCodeSDK.ProcessError
ClaudeCodeSDK.CLIJSONDecodeError
```

## Internal Components

### Transport Layer

```@docs
ClaudeCodeSDK.SubprocessCLITransport
```

## Function Reference

### Main Query Function

**`query(prompt::String; options::Union{ClaudeCodeOptions, Nothing}=nothing)`**

Main function for querying Claude through the CLI.

**Parameters:**
- `prompt::String`: The prompt to send to Claude
- `options::Union{ClaudeCodeOptions, Nothing}`: Optional configuration (default: `nothing`)

**Returns:** `Vector{Message}` - Vector of response messages for easy iteration

**Example:**
```julia
# Basic usage
result = query("Hello Claude")

# With options
options = ClaudeCodeOptions(system_prompt="You are helpful")
result = query("Tell me a joke", options=options)
```

### Configuration Options

**`ClaudeCodeOptions`**

Configuration struct with all available options:

- `allowed_tools::Vector{String}` - Allowed tools list (default: `String[]`)
- `max_thinking_tokens::Int` - Maximum thinking tokens (default: `8000`)
- `system_prompt::Union{String, Nothing}` - System prompt for Claude (default: `nothing`)
- `append_system_prompt::Union{String, Nothing}` - Additional system prompt to append (default: `nothing`)
- `mcp_tools::Vector{String}` - MCP tools to enable (default: `String[]`)
- `mcp_servers::Dict{String, McpServerConfig}` - MCP server configurations (default: `Dict{String, McpServerConfig}()`)
- `permission_mode::Union{String, Nothing}` - Permission mode ("acceptEdits", etc.) (default: `nothing`)
- `continue_conversation::Bool` - Continue previous conversation (default: `false`)
- `resume::Union{String, Nothing}` - Resume from session ID (default: `nothing`)
- `max_turns::Union{Int, Nothing}` - Maximum conversation turns (default: `nothing`)
- `disallowed_tools::Vector{String}` - Tools to disallow (default: `String[]`)
- `model::Union{String, Nothing}` - Claude model to use (default: `nothing`)
- `permission_prompt_tool_name::Union{String, Nothing}` - Permission prompt tool name (default: `nothing`)
- `cwd::Union{String, Nothing}` - Working directory (default: `nothing`)

## Message Types

### AssistantMessage

Represents a message from Claude containing response content.

**Fields:**
- `content::Vector{ContentBlock}` - Vector of content blocks (text, tool use, tool results)

### UserMessage

Represents a message from the user.

**Fields:**
- `content::String` - User message content

### SystemMessage

Represents a system message.

**Fields:**
- `subtype::String` - System message subtype
- `data::Dict{String, Any}` - System message data

### ResultMessage

Represents a result message from tool execution or other operations.

**Fields:**
- `subtype::String` - Result message subtype
- `cost_usd::Float64` - Cost in USD
- `duration_ms::Int` - Duration in milliseconds
- `duration_api_ms::Int` - API duration in milliseconds
- `is_error::Bool` - Whether this is an error result
- `num_turns::Int` - Number of conversation turns
- `session_id::String` - Session identifier
- `total_cost_usd::Float64` - Total cost in USD
- `usage::Union{Dict{String, Any}, Nothing}` - Usage statistics (default: `nothing`)
- `result::Union{String, Nothing}` - Result content (default: `nothing`)

## Content Block Types

### TextBlock

Contains text content from Claude's response.

**Fields:**
- `text::String` - The text content

### ToolUseBlock

Represents Claude's request to use a tool.

**Fields:**
- `id::String` - Tool use identifier
- `name::String` - Tool name
- `input::Dict{String, Any}` - Tool input parameters

### ToolResultBlock

Contains the result of a tool execution.

**Fields:**
- `tool_use_id::String` - ID of the tool use this result corresponds to
- `content::Union{String, Vector{Dict{String, Any}}, Nothing}` - Tool execution result content (default: `nothing`)
- `is_error::Union{Bool, Nothing}` - Whether the tool execution resulted in an error (default: `nothing`)

## Tool Types

### ReadTool

Tool for reading files.

**Fields:**
- `path::String` - Path to file to read

### WriteTool

Tool for writing files.

**Fields:**
- `path::String` - Path to file to write
- `content::String` - Content to write

### BashTool

Tool for executing bash commands.

**Fields:**
- `command::String` - Command to execute

### ToolResult

Result of tool execution.

**Fields:**
- `success::Bool` - Whether the tool execution was successful
- `output::Union{String, Nothing}` - Tool output (default: `nothing`)
- `error::Union{String, Nothing}` - Error message if execution failed (default: `nothing`)

## MCP Configuration

### McpServerConfig

Configuration for MCP (Model Context Protocol) servers.

**Fields:**
- `transport::Vector{String}` - Transport configuration (e.g., command and arguments)
- `env::Union{Dict{String, Any}, Nothing}` - Environment variables (default: `nothing`)