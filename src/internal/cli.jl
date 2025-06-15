"""
Module for managing communication with Claude Code CLI
"""

"""
Transport layer for communicating with Claude Code CLI
"""
mutable struct SubprocessCLITransport
    prompt::String
    options::ClaudeCodeOptions
    process::Union{Base.Process, Nothing}
    
    function SubprocessCLITransport(prompt::String, options::ClaudeCodeOptions)
        new(prompt, options, nothing)
    end
end

"""
Check if CLI is available
"""
function check_cli_available()
    try
        run(pipeline(`claude --version`, devnull))
        return true
    catch e
        if e isa ProcessFailedException || e isa Base.IOError
            return false
        end
        rethrow(e)
    end
end

"""
Connect to the CLI process
"""
function connect!(transport::SubprocessCLITransport)
    if !check_cli_available()
        throw(CLINotFoundError())
    end
    
    # Build command arguments - use --print for non-interactive output and simple text output
    cmd_args = ["claude", "--print"]
    
    # Add allowed tools if specified
    if !isempty(transport.options.allowed_tools)
        push!(cmd_args, "--allowedTools")
        push!(cmd_args, join(transport.options.allowed_tools, " "))
    end
    
    # Add disallowed tools if specified
    if !isempty(transport.options.disallowed_tools)
        push!(cmd_args, "--disallowedTools")
        push!(cmd_args, join(transport.options.disallowed_tools, " "))
    end
    
    # Add model if specified
    if !isnothing(transport.options.model)
        push!(cmd_args, "--model", transport.options.model)
    end
    
    # Add the prompt as the final argument
    push!(cmd_args, transport.prompt)
    
    try
        # Start the process with pipes for communication
        transport.process = open(Cmd(cmd_args), "r")
    catch e
        if e isa ProcessFailedException
            throw(ProcessError(e.exitcode))
        end
        throw(CLIConnectionError(string(e)))
    end
end

"""
Receive messages from the CLI process
"""
function receive_messages(transport::SubprocessCLITransport)
    if isnothing(transport.process)
        throw(CLIConnectionError("Not connected to CLI"))
    end
    
    messages = []
    
    try
        # For basic text output, read all output and create a simple text message
        output = read(transport.process, String)
        if !isempty(strip(output))
            # Create a simple assistant message with text content
            data = Dict(
                "type" => "assistant",
                "message" => Dict(
                    "content" => [Dict(
                        "type" => "text",
                        "text" => strip(output)
                    )]
                )
            )
            push!(messages, data)
        end
    catch e
        if e isa ProcessFailedException
            throw(ProcessError(e.exitcode))
        end
        throw(CLIConnectionError(string(e)))
    end
    
    return messages
end

"""
Disconnect from the CLI process
"""
function disconnect!(transport::SubprocessCLITransport)
    if !isnothing(transport.process)
        close(transport.process)
        transport.process = nothing
    end
end

"""
Parse message from CLI output into typed Message objects
"""
function parse_message(data::Dict{String, Any})
    message_type = get(data, "type", "")
    
    if message_type == "user"
        return UserMessage(data["message"]["content"])
    elseif message_type == "assistant"
        content_blocks = []
        for block in data["message"]["content"]
            block_type = get(block, "type", "")
            if block_type == "text"
                push!(content_blocks, TextBlock(block["text"]))
            elseif block_type == "tool_use"
                push!(content_blocks, ToolUseBlock(
                    block["id"],
                    block["name"], 
                    block["input"]
                ))
            elseif block_type == "tool_result"
                push!(content_blocks, ToolResultBlock(
                    block["tool_use_id"];
                    content=get(block, "content", nothing),
                    is_error=get(block, "is_error", nothing)
                ))
            end
        end
        return AssistantMessage(content_blocks)
    elseif message_type == "system"
        return SystemMessage(
            data["subtype"],
            data  # Pass through all data
        )
    elseif message_type == "result"
        return ResultMessage(
            data["subtype"],
            data["cost_usd"],
            data["duration_ms"], 
            data["duration_api_ms"],
            data["is_error"],
            data["num_turns"],
            data["session_id"],
            data["total_cost"];
            usage=get(data, "usage", nothing),
            result=get(data, "result", nothing)
        )
    end
    
    return nothing
end