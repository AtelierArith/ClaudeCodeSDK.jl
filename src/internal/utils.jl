"""
Utility functions for Claude Code SDK
"""

"""
Convert options to JSON
"""
function options_to_json(options::Union{ClaudeCodeOptions, Nothing})
    if isnothing(options)
        return Dict{String, Any}()
    end

    result = Dict{String, Any}()

    if !isnothing(options.system_prompt)
        result["system_prompt"] = options.system_prompt
    end

    if !isnothing(options.max_turns)
        result["max_turns"] = options.max_turns
    end

    if !isnothing(options.allowed_tools)
        result["allowed_tools"] = options.allowed_tools
    end

    if !isnothing(options.permission_mode)
        result["permission_mode"] = options.permission_mode
    end

    if !isnothing(options.cwd)
        result["cwd"] = options.cwd
    end

    return result
end

"""
Convert message to JSON
"""
function message_to_json(message::Message)
    if message isa AssistantMessage
        return Dict{String, Any}(
            "type" => "assistant",
            "content" => [block_to_json(block) for block in message.content]
        )
    elseif message isa UserMessage
        return Dict{String, Any}(
            "type" => "user",
            "content" => message.content
        )
    elseif message isa SystemMessage
        return Dict{String, Any}(
            "type" => "system",
            "content" => message.content
        )
    elseif message isa ResultMessage
        return Dict{String, Any}(
            "type" => "result",
            "content" => message.content
        )
    end
end

"""
Convert block to JSON
"""
function block_to_json(block::Union{TextBlock, ToolUseBlock, ToolResultBlock})
    if block isa TextBlock
        return Dict{String, Any}(
            "type" => "text",
            "text" => block.text
        )
    elseif block isa ToolUseBlock
        return Dict{String, Any}(
            "type" => "tool_use",
            "tool" => block.tool,
            "args" => block.args
        )
    elseif block isa ToolResultBlock
        return Dict{String, Any}(
            "type" => "tool_result",
            "tool" => block.tool,
            "result" => block.result
        )
    end
end