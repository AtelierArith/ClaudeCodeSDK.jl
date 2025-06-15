"""
Error definitions for Claude Code SDK
"""

"""
Base error type for Claude SDK
"""
struct ClaudeSDKError <: Exception
    msg::String
end

Base.showerror(io::IO, e::ClaudeSDKError) = print(io, "ClaudeSDKError: ", e.msg)

"""
Error when Claude Code CLI is not found
"""
struct CLINotFoundError <: Exception
    msg::String
    function CLINotFoundError()
        new("Claude Code CLI not found. Please install it with: npm install -g @anthropic-ai/claude-code")
    end
end

Base.showerror(io::IO, e::CLINotFoundError) = print(io, "CLINotFoundError: ", e.msg)

"""
CLI connection error
"""
struct CLIConnectionError <: Exception
    msg::String
    function CLIConnectionError(msg::String)
        new("Connection error: $msg")
    end
end

Base.showerror(io::IO, e::CLIConnectionError) = print(io, "CLIConnectionError: ", e.msg)

"""
Process execution error
"""
struct ProcessError <: Exception
    msg::String
    exit_code::Int
    function ProcessError(exit_code::Int)
        new("Process failed with exit code: $exit_code", exit_code)
    end
end

Base.showerror(io::IO, e::ProcessError) = print(io, "ProcessError: ", e.msg)

"""
JSON parsing error
"""
struct CLIJSONDecodeError <: Exception
    msg::String
    function CLIJSONDecodeError(msg::String)
        new("Failed to parse JSON response: $msg")
    end
end

Base.showerror(io::IO, e::CLIJSONDecodeError) = print(io, "CLIJSONDecodeError: ", e.msg)