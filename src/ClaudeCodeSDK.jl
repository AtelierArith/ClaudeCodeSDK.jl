"""
Claude SDK for Julia
"""
module ClaudeCodeSDK

using JSON

# Include type definitions
include("types.jl")
include("errors.jl") 
include("internal/cli.jl")
include("internal/client.jl")
include("internal/utils.jl")
include("internal/tools.jl")

# Main function export
export query, query_stream

# Type exports 
export PermissionMode, McpServerConfig
export UserMessage, AssistantMessage, SystemMessage, ResultMessage, Message
export ClaudeCodeOptions
export TextBlock, ToolUseBlock, ToolResultBlock, ContentBlock

# Error exports
export ClaudeSDKError, CLIConnectionError, CLINotFoundError, ProcessError, CLIJSONDecodeError

# Tool exports (for advanced usage)
export Tool, ReadTool, WriteTool, BashTool, ToolResult
export create_tool_from_block, execute_tool

const __version__ = "0.1.0"

"""
    query(; prompt::String, options::Union{ClaudeCodeOptions, Nothing}=nothing)

Query Claude Code.

Julia SDK for interacting with Claude Code.

# Arguments
- `prompt::String`: The prompt to send to Claude
- `options::Union{ClaudeCodeOptions, Nothing}`: Optional configuration (defaults to ClaudeCodeOptions() if nothing).
  Set options.permission_mode to control tool execution:
  - 'default': CLI prompts for dangerous tools
  - 'acceptEdits': Auto-accept file edits  
  - 'bypassPermissions': Allow all tools (use with caution)
  Set options.cwd for working directory.

# Returns
- `Vector{Message}`: Vector of messages from the conversation

# Examples
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
"""
function query(; prompt::String, options::Union{ClaudeCodeOptions, Nothing}=nothing)
    if options === nothing
        options = ClaudeCodeOptions()
    end
    
    # Set environment variable for SDK identification
    ENV["CLAUDE_CODE_ENTRYPOINT"] = "sdk-jl"
    
    client = InternalClient()
    return process_query(client, prompt, options)
end

"""
    query_stream(; prompt::String, options::Union{ClaudeCodeOptions, Nothing}=nothing)

Query Claude Code with real-time streaming output.

Returns a Channel that yields messages as they arrive from the Claude CLI.

# Arguments
- `prompt::String`: The prompt to send to Claude
- `options::Union{ClaudeCodeOptions, Nothing}`: Optional configuration

# Returns
- `Channel{Message}`: Channel that yields messages as they arrive

# Examples
```julia
# Stream messages in real-time
for message in query_stream(prompt="Write a story")
    if message isa AssistantMessage
        for block in message.content
            if block isa TextBlock
                print(block.text)
                flush(stdout)
            end
        end
    end
end
```
"""
function query_stream(; prompt::String, options::Union{ClaudeCodeOptions, Nothing}=nothing)
    if options === nothing
        options = ClaudeCodeOptions()
    end
    
    # Set environment variable for SDK identification
    ENV["CLAUDE_CODE_ENTRYPOINT"] = "sdk-jl"
    
    client = InternalClient()
    return process_query_stream(client, prompt, options)
end

end # module