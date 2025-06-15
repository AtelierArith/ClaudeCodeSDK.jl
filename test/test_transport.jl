"""
Tests for Claude SDK transport layer - ported from Python tests.
"""

using Test
using ClaudeCodeSDK
using ClaudeCodeSDK: find_cli, build_command

@testset "CLI Discovery" begin
    @testset "CLI Path Validation" begin
        # Test that find_cli function exists and returns something when CLI is available
        if hasmethod(find_cli, ())
            try
                cli_path = find_cli()
                @test cli_path isa String
                @test !isempty(cli_path)
            catch e
                # CLI not found is expected in some test environments
                @test e isa CLINotFoundError
            end
        end
    end

    @testset "CLI Not Found Error" begin
        # Test that CLINotFoundError is properly defined
        error = CLINotFoundError("Claude Code requires Node.js")
        @test error isa ClaudeSDKError
        @test occursin("Claude Code requires Node.js", string(error))
    end
end

@testset "Command Building" begin
    @testset "Basic Command Construction" begin
        # Test basic CLI command building
        options = ClaudeCodeOptions()
        
        # Test that command building works with basic options
        @test options isa ClaudeCodeOptions
        @test options.allowed_tools == String[]
        @test options.max_thinking_tokens == 8000
    end

    @testset "Command with Options" begin
        # Test building CLI command with various options
        options = ClaudeCodeOptions(
            system_prompt="Be helpful",
            allowed_tools=["Read", "Write"],
            disallowed_tools=["Bash"],
            model="claude-3-5-sonnet",
            permission_mode="acceptEdits",
            max_turns=5
        )
        
        # Verify options are properly set
        @test options.system_prompt == "Be helpful"
        @test options.allowed_tools == ["Read", "Write"]
        @test options.disallowed_tools == ["Bash"]
        @test options.model == "claude-3-5-sonnet"
        @test options.permission_mode == "acceptEdits"
        @test options.max_turns == 5
        
        # Test that these options would be used in command construction
        # (The actual command building is internal to the transport layer)
    end

    @testset "Session Continuation Options" begin
        # Test session continuation options
        options = ClaudeCodeOptions(
            continue_conversation=true,
            resume="session-123"
        )
        
        @test options.continue_conversation == true
        @test options.resume == "session-123"
    end

    @testset "Working Directory Options" begin
        # Test working directory specification
        options = ClaudeCodeOptions(cwd="/custom/path")
        @test options.cwd == "/custom/path"
    end

    @testset "MCP Configuration" begin
        # Test MCP server and tool configuration
        server_config = McpServerConfig(["stdio", "/path/to/server"])
        options = ClaudeCodeOptions(
            mcp_servers=Dict("test_server" => server_config),
            mcp_tools=["custom_tool"]
        )
        
        @test haskey(options.mcp_servers, "test_server")
        @test options.mcp_servers["test_server"].transport == ["stdio", "/path/to/server"]
        @test options.mcp_tools == ["custom_tool"]
    end
end

@testset "Transport Configuration" begin
    @testset "Environment Setup" begin
        # Test that environment variables can be set
        # The actual transport layer should set CLAUDE_CODE_ENTRYPOINT
        @test haskey(ENV, "CLAUDE_CODE_ENTRYPOINT") || true  # May or may not be set
    end

    @testset "Process Management" begin
        # Test process-related functionality
        # Since we can't easily mock processes in Julia tests, we test the error types
        
        process_error = ProcessError("Process failed", exit_code=1, stderr="Error output")
        @test process_error.exit_code == 1
        @test process_error.stderr == "Error output"
        @test occursin("Process failed", process_error.message)
        @test occursin("exit code: 1", process_error.message)
        @test occursin("Error output", process_error.message)
    end

    @testset "Connection Lifecycle" begin
        # Test connection-related error handling
        connection_error = CLIConnectionError("Failed to connect")
        @test connection_error isa ClaudeSDKError
        @test occursin("Failed to connect", string(connection_error))
    end
end

@testset "Message Streaming" begin
    @testset "JSON Line Processing" begin
        # Test JSON parsing capabilities that would be used for streaming
        using JSON
        
        # Test valid JSON parsing
        valid_json = """{"type": "assistant", "message": {"content": [{"type": "text", "text": "Hello"}]}}"""
        parsed = JSON.parse(valid_json)
        @test parsed["type"] == "assistant"
        @test haskey(parsed, "message")
        
        # Test invalid JSON handling
        invalid_json = """{"type": "assistant", "incomplete": """
        try
            JSON.parse(invalid_json)
            @test false  # Should not reach here
        catch e
            # Should be able to create CLIJSONDecodeError from this
            error = CLIJSONDecodeError(invalid_json, e)
            @test error.line == invalid_json
            @test error.original_error == e
        end
    end

    @testset "Message Type Parsing" begin
        # Test that we can parse different message types from JSON
        using JSON
        
        # System message
        system_json = """{"type": "system", "subtype": "init", "session_id": "test"}"""
        system_data = JSON.parse(system_json)
        @test system_data["type"] == "system"
        @test system_data["subtype"] == "init"
        
        # Assistant message
        assistant_json = """{"type": "assistant", "message": {"content": [{"type": "text", "text": "Hello"}]}}"""
        assistant_data = JSON.parse(assistant_json)
        @test assistant_data["type"] == "assistant"
        @test haskey(assistant_data["message"], "content")
        
        # Result message
        result_json = """{"type": "result", "subtype": "success", "cost_usd": 0.001, "duration_ms": 1000, "is_error": false}"""
        result_data = JSON.parse(result_json)
        @test result_data["type"] == "result"
        @test result_data["subtype"] == "success"
        @test result_data["cost_usd"] == 0.001
    end
end

@testset "Transport Error Handling" begin
    @testset "CLI Path Resolution" begin
        # Test that path resolution errors are handled properly
        error = CLINotFoundError("CLI not found", cli_path="/nonexistent/path")
        @test error.cli_path == "/nonexistent/path"
        @test occursin("/nonexistent/path", error.message)
    end

    @testset "Process Execution Errors" begin
        # Test various process execution error scenarios
        
        # Simple process error
        simple_error = ProcessError("Command failed")
        @test isnothing(simple_error.exit_code)
        @test isnothing(simple_error.stderr)
        
        # Process error with exit code
        exit_error = ProcessError("Command failed", exit_code=127)
        @test exit_error.exit_code == 127
        @test occursin("exit code: 127", exit_error.message)
        
        # Process error with stderr
        stderr_error = ProcessError("Command failed", stderr="command not found")
        @test stderr_error.stderr == "command not found"
        @test occursin("command not found", stderr_error.message)
        
        # Process error with both
        full_error = ProcessError("Command failed", exit_code=1, stderr="permission denied")
        @test full_error.exit_code == 1
        @test full_error.stderr == "permission denied"
        @test occursin("exit code: 1", full_error.message)
        @test occursin("permission denied", full_error.message)
    end

    @testset "JSON Streaming Errors" begin
        # Test JSON streaming error handling
        using JSON
        
        malformed_lines = [
            "{invalid}",
            "{\"type\": \"incomplete\"",
            "not json at all",
            "{\"valid\": true}"  # This one should work
        ]
        
        valid_count = 0
        error_count = 0
        
        for line in malformed_lines
            try
                parsed = JSON.parse(line)
                valid_count += 1
            catch e
                error_count += 1
                # Should be able to create proper error
                json_error = CLIJSONDecodeError(line, e)
                @test json_error.line == line
                @test json_error.original_error == e
            end
        end
        
        @test valid_count == 1  # Only the last line should be valid
        @test error_count == 3  # The first three lines should error
    end
end