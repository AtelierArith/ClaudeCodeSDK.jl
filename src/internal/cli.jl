"""
Subprocess transport implementation using Claude Code CLI
"""

using JSON

"""
Transport layer for communicating with Claude Code CLI
"""
mutable struct SubprocessCLITransport
    prompt::String
    options::ClaudeCodeOptions
    cli_path::String
    cwd::Union{String, Nothing}
    process::Union{Base.Process, String, Nothing}
    
    function SubprocessCLITransport(prompt::String, options::ClaudeCodeOptions; cli_path=nothing)
        cli = cli_path !== nothing ? cli_path : find_cli()
        working_dir = options.cwd !== nothing ? string(options.cwd) : nothing
        new(prompt, options, cli, working_dir, nothing)
    end
end

"""
Find Claude Code CLI binary
"""
function find_cli()
    # First try system PATH
    claude_cmd = Sys.which("claude")
    if claude_cmd !== nothing
        return claude_cmd
    end
    
    # Try common installation locations
    locations = [
        joinpath(homedir(), ".npm-global", "bin", "claude"),
        "/usr/local/bin/claude",
        joinpath(homedir(), ".local", "bin", "claude"),
        joinpath(homedir(), "node_modules", ".bin", "claude"),
        joinpath(homedir(), ".yarn", "bin", "claude")
    ]
    
    for path in locations
        if isfile(path)
            return path
        end
    end
    
    # Check if Node.js is installed
    node_installed = Sys.which("node") !== nothing
    
    if !node_installed
        error_msg = """Claude Code requires Node.js, which is not installed.

Install Node.js from: https://nodejs.org/

After installing Node.js, install Claude Code:
  npm install -g @anthropic-ai/claude-code"""
        throw(CLINotFoundError(error_msg))
    end
    
    error_msg = """Claude Code not found. Install with:
  npm install -g @anthropic-ai/claude-code

If already installed locally, try:
  export PATH="\$HOME/node_modules/.bin:\$PATH"

Or specify the path when creating transport:
  SubprocessCLITransport(..., cli_path="/path/to/claude")"""
    throw(CLINotFoundError(error_msg))
end

"""
Build CLI command with arguments
"""
function build_command(transport::SubprocessCLITransport)
    cmd = [transport.cli_path, "--output-format", "stream-json", "--verbose"]
    
    if transport.options.system_prompt !== nothing
        push!(cmd, "--system-prompt", transport.options.system_prompt)
    end
    
    if transport.options.append_system_prompt !== nothing
        push!(cmd, "--append-system-prompt", transport.options.append_system_prompt)
    end
    
    if !isempty(transport.options.allowed_tools)
        push!(cmd, "--allowedTools", join(transport.options.allowed_tools, ","))
    end
    
    if transport.options.max_turns !== nothing
        push!(cmd, "--max-turns", string(transport.options.max_turns))
    end
    
    if !isempty(transport.options.disallowed_tools)
        push!(cmd, "--disallowedTools", join(transport.options.disallowed_tools, ","))
    end
    
    if transport.options.model !== nothing
        push!(cmd, "--model", transport.options.model)
    end
    
    if transport.options.permission_prompt_tool_name !== nothing
        push!(cmd, "--permission-prompt-tool", transport.options.permission_prompt_tool_name)
    end
    
    if transport.options.permission_mode !== nothing
        push!(cmd, "--permission-mode", transport.options.permission_mode)
    end
    
    if transport.options.continue_conversation
        push!(cmd, "--continue")
    end
    
    if transport.options.resume !== nothing
        push!(cmd, "--resume", transport.options.resume)
    end
    
    if !isempty(transport.options.mcp_servers)
        mcp_config = Dict("mcpServers" => transport.options.mcp_servers)
        push!(cmd, "--mcp-config", JSON.json(mcp_config))
    end
    
    push!(cmd, "--print", transport.prompt)
    return cmd
end

"""
Connect to the CLI process
"""
function connect!(transport::SubprocessCLITransport)
    # For our simplified implementation, we don't need to keep process open
    # We'll execute the command in receive_messages
    transport.process = "ready"  # Just a flag to indicate readiness
end

"""
Receive messages from the CLI process
"""
function receive_messages(transport::SubprocessCLITransport)
    if transport.process === nothing
        throw(CLIConnectionError("Not connected"))
    end
    
    cmd = build_command(transport)
    
    try
        # Set environment variable for SDK identification
        env = copy(ENV)
        env["CLAUDE_CODE_ENTRYPOINT"] = "sdk-jl"
        
        # Create command with environment
        cmd_obj = setenv(Cmd(cmd), env)
        
        # Execute command and capture output
        if transport.cwd !== nothing
            # Change to working directory temporarily
            original_pwd = pwd()
            cd(transport.cwd)
            try
                output = read(cmd_obj, String)
            finally
                cd(original_pwd)
            end
        else
            output = read(cmd_obj, String)
        end
        
        # Parse each line as JSON
        messages = []
        for line in split(output, '\n')
            line_str = strip(line)
            if isempty(line_str)
                continue
            end
            
            try
                data = JSON.parse(line_str)
                push!(messages, data)
            catch e
                if startswith(line_str, "{") || startswith(line_str, "[")
                    throw(CLIJSONDecodeError(line_str, e))
                end
                # Skip non-JSON lines (might be debug output)
                continue
            end
        end
        
        return messages
        
    catch e
        if e isa ProcessFailedException
            throw(ProcessError(
                "CLI process failed";
                exit_code=e.exitcode,
                stderr="Process exited with code $(e.exitcode)"
            ))
        elseif e isa CLIJSONDecodeError
            rethrow(e)
        elseif e isa SystemError && e.errnum == 2  # File not found
            throw(CLINotFoundError("Claude Code not found at: $(transport.cli_path)"; cli_path=transport.cli_path))
        else
            throw(CLIConnectionError("Failed to execute Claude Code: $e"))
        end
    end
end

"""
Disconnect from the CLI process
"""
function disconnect!(transport::SubprocessCLITransport)
    # In our simplified implementation, nothing to disconnect
    transport.process = nothing
end

"""
Check if transport is connected
"""
function is_connected(transport::SubprocessCLITransport)
    return transport.process !== nothing
end

"""
Parse message from CLI output into typed Message objects
"""
function parse_message(data::Dict{String, Any})
    message_type = get(data, "type", "")
    
    if message_type == "user"
        # Extract just the content from the nested structure
        content = data["message"]["content"]
        # Handle both string and array content
        if content isa String
            return UserMessage(content)
        elseif content isa Vector
            # If it's an array, extract text from the first text block
            for block in content
                if haskey(block, "text")
                    return UserMessage(block["text"])
                end
            end
            # Fallback: join all text content
            return UserMessage(join([get(block, "text", "") for block in content], " "))
        else
            return UserMessage(string(content))
        end
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
            get(data, "cost_usd", data["total_cost_usd"]),  # Use total_cost_usd as fallback
            data["duration_ms"], 
            data["duration_api_ms"],
            data["is_error"],
            data["num_turns"],
            data["session_id"],
            data["total_cost_usd"];
            usage=get(data, "usage", nothing),
            result=get(data, "result", nothing)
        )
    end
    
    return nothing
end