"""
Error definitions for Claude Code SDK
"""

"""
Base error type for Claude SDK
"""
abstract type ClaudeSDKError <: Exception end

"""
Error when Claude Code CLI is not found
"""
struct CLINotFoundError <: ClaudeSDKError
    message::String
    cli_path::Union{String, Nothing}
    
    function CLINotFoundError(message::String="Claude Code not found"; cli_path=nothing)
        if cli_path !== nothing
            message = "$message: $cli_path"
        end
        new(message, cli_path)
    end
end

Base.showerror(io::IO, e::CLINotFoundError) = print(io, "CLINotFoundError: ", e.message)

"""
CLI connection error
"""
struct CLIConnectionError <: ClaudeSDKError
    message::String
    
    CLIConnectionError(message::String) = new(message)
end

Base.showerror(io::IO, e::CLIConnectionError) = print(io, "CLIConnectionError: ", e.message)

"""
Process execution error
"""
struct ProcessError <: ClaudeSDKError
    message::String
    exit_code::Union{Int, Nothing}
    stderr::Union{String, Nothing}
    
    function ProcessError(message::String; exit_code=nothing, stderr=nothing)
        full_message = message
        if exit_code !== nothing
            full_message = "$message (exit code: $exit_code)"
        end
        if stderr !== nothing
            full_message = "$full_message\nError output: $stderr"
        end
        new(full_message, exit_code, stderr)
    end
end

Base.showerror(io::IO, e::ProcessError) = print(io, "ProcessError: ", e.message)

"""
JSON parsing error
"""
struct CLIJSONDecodeError <: ClaudeSDKError
    message::String
    line::String
    original_error::Exception
    
    function CLIJSONDecodeError(line::String, original_error::Exception)
        truncated_line = length(line) > 100 ? line[1:100] * "..." : line
        message = "Failed to decode JSON: $truncated_line"
        new(message, line, original_error)
    end
end

Base.showerror(io::IO, e::CLIJSONDecodeError) = print(io, "CLIJSONDecodeError: ", e.message)