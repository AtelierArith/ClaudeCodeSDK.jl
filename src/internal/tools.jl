"""
Tool execution functionality for Claude Code SDK
"""

"""
Create a tool instance from a ToolUseBlock
"""
function create_tool_from_block(block::ToolUseBlock)
    if block.name == "Read"
        path = get(block.input, "file_path", "")
        return ReadTool(path)
    elseif block.name == "Write"
        path = get(block.input, "file_path", "")
        content = get(block.input, "content", "")
        return WriteTool(path, content)
    elseif block.name == "Bash"
        command = get(block.input, "command", "")
        return BashTool(command)
    end
    
    return nothing
end

"""
Execute a tool and return the result
"""
function execute_tool(tool::Tool)
    if tool isa ReadTool
        return execute_read_tool(tool)
    elseif tool isa WriteTool
        return execute_write_tool(tool)
    elseif tool isa BashTool
        return execute_bash_tool(tool)
    end
    
    return ToolResult(false, nothing, "Unknown tool type")
end

"""
Execute a Read tool
"""
function execute_read_tool(tool::ReadTool)
    try
        if isfile(tool.path)
            content = read(tool.path, String)
            return ToolResult(true, content, nothing)
        else
            return ToolResult(false, nothing, "File not found: $(tool.path)")
        end
    catch e
        return ToolResult(false, nothing, string(e))
    end
end

"""
Execute a Write tool
"""
function execute_write_tool(tool::WriteTool)
    try
        # Create directory if it doesn't exist
        dir = dirname(tool.path)
        if !isdir(dir) && !isempty(dir)
            mkpath(dir)
        end
        
        write(tool.path, tool.content)
        return ToolResult(true, "File written successfully", nothing)
    catch e
        return ToolResult(false, nothing, string(e))
    end
end

"""
Execute a Bash tool
"""
function execute_bash_tool(tool::BashTool)
    try
        result = read(Cmd(split(tool.command)), String)
        return ToolResult(true, result, nothing)
    catch e
        if e isa ProcessFailedException
            return ToolResult(false, nothing, "Process failed with exit code: $(e.exitcode)")
        else
            return ToolResult(false, nothing, string(e))
        end
    end
end
