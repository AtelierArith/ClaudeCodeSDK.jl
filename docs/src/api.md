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

- `system_prompt::Union{String, Nothing}` - System prompt for Claude (default: `nothing`)
- `max_turns::Union{Int, Nothing}` - Maximum conversation turns (default: `nothing`)
- `cwd::Union{String, Nothing}` - Working directory (default: `nothing`)
- `allowed_tools::Union{Vector{String}, Nothing}` - Allowed tools list (default: `nothing`)
- `permission_mode::Union{String, Nothing}` - Permission mode ("acceptEdits", etc.) (default: `nothing`)
- `model::Union{String, Nothing}` - Claude model to use (default: `nothing`)
- `enable_mcp::Union{Bool, Nothing}` - Enable MCP servers (default: `nothing`)
- `mcp_server_configs::Union{Dict, Nothing}` - MCP server configurations (default: `nothing`)
- `suppress_client_logs::Union{Bool, Nothing}` - Suppress client logs (default: `nothing`)
- `custom_instructions::Union{String, Nothing}` - Custom instructions (default: `nothing`)
- `memory_path::Union{String, Nothing}` - Memory file path (default: `nothing`)
- `memory_disabled::Union{Bool, Nothing}` - Disable memory (default: `nothing`)
- `test_mode::Union{Bool, Nothing}` - Enable test mode (default: `nothing`)
- `disable_tools::Union{Vector{String}, Nothing}` - Tools to disable (default: `nothing`)

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
- `content::String` - System message content

### ResultMessage

Represents a result message from tool execution or other operations.

**Fields:**
- `content::String` - Result content

## Content Block Types

### TextBlock

Contains text content from Claude's response.

**Fields:**
- `text::String` - The text content

### ToolUseBlock

Represents Claude's request to use a tool.

**Fields:**
- `tool::String` - Tool name
- `args::Dict{String, Any}` - Tool arguments

### ToolResultBlock

Contains the result of a tool execution.

**Fields:**
- `result::String` - Tool execution result

## Tool Types

### ReadTool

Tool for reading files.

**Fields:**
- `file_path::String` - Path to file to read

### WriteTool

Tool for writing files.

**Fields:**
- `file_path::String` - Path to file to write
- `content::String` - Content to write

### BashTool

Tool for executing bash commands.

**Fields:**
- `command::String` - Command to execute