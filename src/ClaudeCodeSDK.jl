module ClaudeCodeSDK

using JSON
using HTTP

include("types.jl")
include("errors.jl")
include("internal/cli.jl")
include("internal/utils.jl")
include("internal/tools.jl")

export query, ClaudeCodeOptions, AssistantMessage, TextBlock, ToolUseBlock, ToolResultBlock
export ClaudeSDKError, CLINotFoundError, CLIConnectionError, ProcessError
export Tool, ReadTool, WriteTool, BashTool, ToolResult
export create_tool_from_block, execute_tool

"""
Internal client implementation
"""
struct InternalClient
end

"""
Process a query through transport layer
"""
function process_query(::InternalClient, prompt::String, options::ClaudeCodeOptions)
    transport = SubprocessCLITransport(prompt, options)
    
    messages = Message[]
    
    try
        connect!(transport)
        
        for data in receive_messages(transport)
            message = parse_message(data)
            if !isnothing(message)
                push!(messages, message)
            end
        end
        
    finally
        disconnect!(transport)
    end
    
    return messages
end

"""
    query(prompt::String; options::Union{ClaudeCodeOptions, Nothing}=nothing)

Send a query to Claude Code and return the response

# Arguments
- `prompt::String`: The prompt to send
- `options::Union{ClaudeCodeOptions, Nothing}`: Configuration options (optional)

# Returns
- Vector{Message}: Vector of messages (AssistantMessage, UserMessage, SystemMessage, or ResultMessage)

# Examples
```julia
for message in query("What is 2 + 2?")
    if message isa AssistantMessage
        for block in message.content
            if block isa TextBlock
                println(block.text)
            end
        end
    end
end
```
"""
function query(prompt::String; options::Union{ClaudeCodeOptions, Nothing}=nothing)
    # Create default options if none provided
    opts = isnothing(options) ? ClaudeCodeOptions() : options
    
    # Create client and process query
    client = InternalClient()
    return process_query(client, prompt, opts)
end

end # module