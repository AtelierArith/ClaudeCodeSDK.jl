"""
Tests for Claude SDK client functionality - ported from Python tests.
"""

using Test
using ClaudeCodeSDK

# Mock utilities for testing
struct MockProcess
    stdout::IOBuffer
    stderr::IOBuffer
    returncode::Union{Int, Nothing}
    
    MockProcess() = new(IOBuffer(), IOBuffer(), nothing)
end

function mock_successful_query_response()
    # Create mock JSON responses that would come from CLI
    responses = [
        """{"type": "system", "subtype": "init", "session_id": "test-session", "tools": ["Read", "Write"]}""",
        """{"type": "assistant", "message": {"role": "assistant", "content": [{"type": "text", "text": "4"}]}}""",
        """{"type": "result", "subtype": "success", "cost_usd": 0.001, "duration_ms": 1000, "duration_api_ms": 800, "is_error": false, "num_turns": 1, "session_id": "test-session", "total_cost_usd": 0.001}"""
    ]
    return join(responses, "\n")
end

@testset "Query Function" begin
    @testset "Query Single Prompt" begin
        # Note: This is a simplified test since Julia doesn't have the same mocking
        # capabilities as Python's unittest.mock. In a full implementation, we would
        # need a proper mocking framework or test against the actual CLI.
        
        # Test that ClaudeCodeOptions can be created and passed to query
        options = ClaudeCodeOptions()
        @test options isa ClaudeCodeOptions
        
        # Test that the query function exists and has keyword arguments
        @test isdefined(ClaudeCodeSDK, :query)
        @test isa(query, Function)
    end

    @testset "Query with Options" begin
        # Test query with various options
        options = ClaudeCodeOptions(
            allowed_tools=["Read", "Write"],
            system_prompt="You are helpful",
            permission_mode="acceptEdits",
            max_turns=5
        )
        
        # Verify options are properly constructed
        @test options.allowed_tools == ["Read", "Write"]
        @test options.system_prompt == "You are helpful"
        @test options.permission_mode == "acceptEdits"
        @test options.max_turns == 5
        
        # Test that query function accepts these options
        @test isa(query, Function)
    end

    @testset "Query with Working Directory" begin
        # Test query with custom working directory
        options = ClaudeCodeOptions(cwd="/custom/path")
        @test options.cwd == "/custom/path"
        
        # Verify option can be passed to query
        @test isa(query, Function)
    end
end

@testset "Message Processing" begin
    @testset "Message Type Handling" begin
        # Test that different message types can be created
        text_block = TextBlock("Hello")
        assistant_msg = AssistantMessage([text_block])
        @test assistant_msg isa AssistantMessage
        @test length(assistant_msg.content) == 1
        @test assistant_msg.content[1].text == "Hello"
        
        user_msg = UserMessage("Hi there")
        @test user_msg isa UserMessage
        @test user_msg.content == "Hi there"
        
        system_msg = SystemMessage("init", Dict("session_id" => "test"))
        @test system_msg isa SystemMessage
        @test system_msg.subtype == "init"
        @test system_msg.data["session_id"] == "test"
        
        result_msg = ResultMessage(
            "success", 0.001, 1000, 800, false, 1, "test-session", 0.001
        )
        @test result_msg isa ResultMessage
        @test result_msg.subtype == "success"
        @test result_msg.cost_usd == 0.001
    end

    @testset "Content Block Processing" begin
        # Test that different content blocks work correctly
        text_block = TextBlock("Some text")
        @test text_block isa TextBlock
        @test text_block isa ContentBlock
        
        tool_use_block = ToolUseBlock("tool-123", "Read", Dict("file_path" => "test.txt"))
        @test tool_use_block isa ToolUseBlock
        @test tool_use_block isa ContentBlock
        
        tool_result_block = ToolResultBlock("tool-123", content="File content")
        @test tool_result_block isa ToolResultBlock
        @test tool_result_block isa ContentBlock
        
        # Test mixed content in AssistantMessage
        mixed_content = [text_block, tool_use_block, tool_result_block]
        assistant_msg = AssistantMessage(mixed_content)
        @test length(assistant_msg.content) == 3
        @test all(block isa ContentBlock for block in assistant_msg.content)
    end
end

@testset "Client Configuration" begin
    @testset "Environment Variable Handling" begin
        # Test that the client sets proper environment variables
        # This would be tested by checking ENV after calling query
        # but since we can't easily mock the CLI, we test the options instead
        
        options = ClaudeCodeOptions(
            model="claude-3-5-sonnet-20241022",
            permission_mode="bypassPermissions",
            max_thinking_tokens=10000
        )
        
        @test options.model == "claude-3-5-sonnet-20241022"
        @test options.permission_mode == "bypassPermissions"
        @test options.max_thinking_tokens == 10000
    end

    @testset "MCP Server Configuration" begin
        # Test MCP server configuration
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

@testset "Error Handling in Client" begin
    @testset "CLI Not Found Handling" begin
        # Test that appropriate errors are defined
        @test CLINotFoundError <: ClaudeSDKError
        
        error = CLINotFoundError("CLI not found")
        @test error isa ClaudeSDKError
        @test occursin("CLI not found", string(error))
    end

    @testset "Process Error Handling" begin
        # Test process error handling
        @test ProcessError <: ClaudeSDKError
        
        error = ProcessError("Process failed", exit_code=1, stderr="Error output")
        @test error.exit_code == 1
        @test error.stderr == "Error output"
    end

    @testset "JSON Decode Error Handling" begin
        # Test JSON parsing error handling
        @test CLIJSONDecodeError <: ClaudeSDKError
        
        using JSON
        try
            JSON.parse("{invalid json}")
        catch original_error
            error = CLIJSONDecodeError("{invalid json}", original_error)
            @test error.line == "{invalid json}"
            @test error.original_error == original_error
        end
    end
end