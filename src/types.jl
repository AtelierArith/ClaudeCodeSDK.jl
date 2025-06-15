"""
Type definitions for Claude Code SDK
"""

# Permission modes
const PermissionMode = Union{String, Nothing}

# MCP Server config
struct McpServerConfig
    transport::Vector{String}
    env::Union{Dict{String, Any}, Nothing}

    function McpServerConfig(transport::Vector{String}; env=nothing)
        new(transport, env)
    end
end

"""
Configuration options for Claude Code
"""
struct ClaudeCodeOptions
    allowed_tools::Vector{String}
    max_thinking_tokens::Int
    system_prompt::Union{String, Nothing}
    append_system_prompt::Union{String, Nothing}
    mcp_tools::Vector{String}
    mcp_servers::Dict{String, McpServerConfig}
    permission_mode::PermissionMode
    continue_conversation::Bool
    resume::Union{String, Nothing}
    max_turns::Union{Int, Nothing}
    disallowed_tools::Vector{String}
    model::Union{String, Nothing}
    permission_prompt_tool_name::Union{String, Nothing}
    cwd::Union{String, Nothing}

    function ClaudeCodeOptions(;
        allowed_tools=String[],
        max_thinking_tokens=8000,
        system_prompt=nothing,
        append_system_prompt=nothing,
        mcp_tools=String[],
        mcp_servers=Dict{String, McpServerConfig}(),
        permission_mode=nothing,
        continue_conversation=false,
        resume=nothing,
        max_turns=nothing,
        disallowed_tools=String[],
        model=nothing,
        permission_prompt_tool_name=nothing,
        cwd=nothing
    )
        new(allowed_tools, max_thinking_tokens, system_prompt, append_system_prompt,
            mcp_tools, mcp_servers, permission_mode, continue_conversation, resume,
            max_turns, disallowed_tools, model, permission_prompt_tool_name, cwd)
    end
end

"""
Base type for messages
"""
abstract type Message end

"""
Text content block
"""
struct TextBlock
    text::String
end

"""
Tool use content block
"""
struct ToolUseBlock
    id::String
    name::String
    input::Dict{String, Any}
end

"""
Tool result content block
"""
struct ToolResultBlock
    tool_use_id::String
    content::Union{String, Vector{Dict{String, Any}}, Nothing}
    is_error::Union{Bool, Nothing}

    function ToolResultBlock(tool_use_id::String; content=nothing, is_error=nothing)
        new(tool_use_id, content, is_error)
    end
end

"""
Message from assistant
"""
struct AssistantMessage <: Message
    content::Vector{Union{TextBlock, ToolUseBlock, ToolResultBlock}}
end

"""
Message from user
"""
struct UserMessage <: Message
    content::String
end

"""
System message
"""
struct SystemMessage <: Message
    subtype::String
    data::Dict{String, Any}
end

"""
Result message
"""
struct ResultMessage <: Message
    subtype::String
    cost_usd::Float64
    duration_ms::Int
    duration_api_ms::Int
    is_error::Bool
    num_turns::Int
    session_id::String
    total_cost_usd::Float64
    usage::Union{Dict{String, Any}, Nothing}
    result::Union{String, Nothing}

    function ResultMessage(subtype::String, cost_usd::Float64, duration_ms::Int, 
                          duration_api_ms::Int, is_error::Bool, num_turns::Int,
                          session_id::String, total_cost_usd::Float64;
                          usage=nothing, result=nothing)
        new(subtype, cost_usd, duration_ms, duration_api_ms, is_error, num_turns,
            session_id, total_cost_usd, usage, result)
    end
end

"""
Base type for tools
"""
abstract type Tool end

"""
Read tool
"""
struct ReadTool <: Tool
    path::String
end

"""
Write tool
"""
struct WriteTool <: Tool
    path::String
    content::String
end

"""
Bash tool
"""
struct BashTool <: Tool
    command::String
end

"""
Tool execution result
"""
struct ToolResult
    success::Bool
    output::Union{String, Nothing}
    error::Union{String, Nothing}
end