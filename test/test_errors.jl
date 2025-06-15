"""
Tests for Claude SDK error handling - ported from Python tests.
"""

using Test
using ClaudeCodeSDK
using JSON

@testset "Error Types" begin
    @testset "Base Error" begin
        # Test base ClaudeSDKError behavior
        @test CLINotFoundError <: ClaudeSDKError
        @test CLIConnectionError <: ClaudeSDKError
        @test ProcessError <: ClaudeSDKError
        @test CLIJSONDecodeError <: ClaudeSDKError
        @test ClaudeSDKError <: Exception
    end

    @testset "CLINotFoundError" begin
        # Test CLINotFoundError creation and properties
        error = CLINotFoundError("Claude Code not found")
        @test error isa ClaudeSDKError
        @test occursin("Claude Code not found", string(error))
        
        # Test with cli_path
        error_with_path = CLINotFoundError("Claude Code not found", cli_path="/usr/bin/claude")
        @test error_with_path.cli_path == "/usr/bin/claude"
        @test occursin("/usr/bin/claude", error_with_path.message)
    end

    @testset "CLIConnectionError" begin
        # Test CLIConnectionError
        error = CLIConnectionError("Failed to connect to CLI")
        @test error isa ClaudeSDKError
        @test occursin("Failed to connect to CLI", string(error))
    end

    @testset "ProcessError" begin
        # Test ProcessError with exit code and stderr
        error = ProcessError("Process failed", exit_code=1, stderr="Command not found")
        @test error.exit_code == 1
        @test error.stderr == "Command not found"
        @test occursin("Process failed", string(error))
        @test occursin("exit code: 1", error.message)
        @test occursin("Command not found", error.message)
        
        # Test ProcessError without optional fields
        simple_error = ProcessError("Simple failure")
        @test isnothing(simple_error.exit_code)
        @test isnothing(simple_error.stderr)
    end

    @testset "CLIJSONDecodeError" begin
        # Test CLIJSONDecodeError
        invalid_json = "{invalid json}"
        
        try
            JSON.parse(invalid_json)
            @test false  # Should not reach here
        catch original_error
            error = CLIJSONDecodeError(invalid_json, original_error)
            @test error.line == invalid_json
            @test error.original_error == original_error
            @test occursin("Failed to decode JSON", string(error))
            @test occursin("invalid json", error.message)
        end
        
        # Test with long line truncation
        long_json = "{" * "x"^200 * "}"
        try
            JSON.parse(long_json)
            @test false  # Should not reach here
        catch original_error
            error = CLIJSONDecodeError(long_json, original_error)
            @test length(error.message) < length(long_json)  # Should be truncated
            @test occursin("...", error.message)  # Should have truncation indicator
        end
    end

    @testset "Error String Representations" begin
        # Test that all errors have proper string representations
        cli_not_found = CLINotFoundError("CLI missing")
        @test occursin("CLINotFoundError", string(cli_not_found))
        
        connection_error = CLIConnectionError("Connection failed")
        @test occursin("CLIConnectionError", string(connection_error))
        
        process_error = ProcessError("Process failed")
        @test occursin("ProcessError", string(process_error))
        
        try
            JSON.parse("{bad}")
        catch e
            json_error = CLIJSONDecodeError("{bad}", e)
            @test occursin("CLIJSONDecodeError", string(json_error))
        end
    end

    @testset "Error Inheritance" begin
        # Test that all specific errors inherit from ClaudeSDKError
        @test CLINotFoundError("test") isa ClaudeSDKError
        @test CLIConnectionError("test") isa ClaudeSDKError
        @test ProcessError("test") isa ClaudeSDKError
        
        try
            JSON.parse("{invalid}")
        catch e
            @test CLIJSONDecodeError("{invalid}", e) isa ClaudeSDKError
        end
    end
end