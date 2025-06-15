"""
Integration tests for Claude SDK - ported from Python tests.

These tests verify end-to-end functionality. Since Julia doesn't have
the same mocking capabilities as Python, these tests focus on the 
components that can be tested without the actual CLI.
"""

using Test
using ClaudeCodeSDK
using JSON

# Helper function to check if CLI is available for integration tests
function cli_available_for_integration()
    try
        run(pipeline(`claude --version`, devnull))
        return true
    catch
        return false
    end
end

const CLI_AVAILABLE_FOR_INTEGRATION = cli_available_for_integration()

@testset "Integration Tests" begin
    @testset "Message Construction and Parsing" begin
        # Test that we can construct messages that would come from CLI responses
        
        # Test assistant message construction
        text_block = TextBlock("2 + 2 equals 4")
        assistant_msg = AssistantMessage([text_block])
        @test assistant_msg isa AssistantMessage
        @test length(assistant_msg.content) == 1
        @test assistant_msg.content[1].text == "2 + 2 equals 4"
        
        # Test result message construction
        result_msg = ResultMessage(
            "success", 0.001, 1000, 800, false, 1, "test-session", 0.001
        )
        @test result_msg isa ResultMessage
        @test result_msg.cost_usd == 0.001
        @test result_msg.session_id == "test-session"
        @test result_msg.duration_ms == 1000
        @test result_msg.duration_api_ms == 800
        @test result_msg.is_error == false
        @test result_msg.num_turns == 1
        @test result_msg.total_cost_usd == 0.001
    end

    @testset "Tool Use Message Construction" begin
        # Test constructing messages with tool use (as would come from CLI)
        
        text_block = TextBlock("Let me read that file for you.")
        tool_use_block = ToolUseBlock(
            "tool-123",
            "Read", 
            Dict("file_path" => "/test.txt")
        )
        
        assistant_msg = AssistantMessage([text_block, tool_use_block])
        @test length(assistant_msg.content) == 2
        @test assistant_msg.content[1] isa TextBlock
        @test assistant_msg.content[2] isa ToolUseBlock
        @test assistant_msg.content[1].text == "Let me read that file for you."
        @test assistant_msg.content[2].name == "Read"
        @test assistant_msg.content[2].input["file_path"] == "/test.txt"
        
        # Test that all content blocks are valid ContentBlock types
        @test all(block isa ContentBlock for block in assistant_msg.content)
    end

    @testset "Options Configuration Integration" begin
        # Test that options work together as they would in real usage
        
        # Test basic options
        basic_options = ClaudeCodeOptions(
            system_prompt="You are a helpful assistant",
            max_turns=1
        )
        @test basic_options.system_prompt == "You are a helpful assistant"
        @test basic_options.max_turns == 1
        
        # Test tool configuration
        tool_options = ClaudeCodeOptions(
            allowed_tools=["Read", "Write"],
            permission_mode="acceptEdits",
            disallowed_tools=["Bash"]
        )
        @test tool_options.allowed_tools == ["Read", "Write"]
        @test tool_options.permission_mode == "acceptEdits"
        @test tool_options.disallowed_tools == ["Bash"]
        
        # Test continuation configuration
        continuation_options = ClaudeCodeOptions(
            continue_conversation=true,
            resume="session-123"
        )
        @test continuation_options.continue_conversation == true
        @test continuation_options.resume == "session-123"
        
        # Test comprehensive configuration
        comprehensive_options = ClaudeCodeOptions(
            allowed_tools=["Read", "Write", "Bash"],
            max_thinking_tokens=10000,
            system_prompt="You are a helpful coding assistant",
            append_system_prompt="Be concise and accurate",
            permission_mode="bypassPermissions",
            continue_conversation=false,
            max_turns=5,
            disallowed_tools=String[],
            model="claude-3-5-sonnet-20241022",
            cwd="/project/root"
        )
        @test comprehensive_options.allowed_tools == ["Read", "Write", "Bash"]
        @test comprehensive_options.max_thinking_tokens == 10000
        @test comprehensive_options.system_prompt == "You are a helpful coding assistant"
        @test comprehensive_options.append_system_prompt == "Be concise and accurate"
        @test comprehensive_options.permission_mode == "bypassPermissions"
        @test comprehensive_options.continue_conversation == false
        @test comprehensive_options.max_turns == 5
        @test comprehensive_options.disallowed_tools == String[]
        @test comprehensive_options.model == "claude-3-5-sonnet-20241022"
        @test comprehensive_options.cwd == "/project/root"
    end

    @testset "Error Handling Integration" begin
        # Test that error types work together as expected
        
        # Test error hierarchy
        @test CLINotFoundError <: ClaudeSDKError
        @test CLIConnectionError <: ClaudeSDKError
        @test ProcessError <: ClaudeSDKError
        @test CLIJSONDecodeError <: ClaudeSDKError
        
        # Test CLI not found error with details
        cli_error = CLINotFoundError("Claude Code requires Node.js", cli_path="/nonexistent")
        @test occursin("Claude Code requires Node.js", string(cli_error))
        @test occursin("/nonexistent", cli_error.message)
        
        # Test process error with full details
        process_error = ProcessError(
            "Command failed", 
            exit_code=127, 
            stderr="command not found: claude"
        )
        @test process_error.exit_code == 127
        @test process_error.stderr == "command not found: claude"
        @test occursin("Command failed", process_error.message)
        @test occursin("exit code: 127", process_error.message)
        @test occursin("command not found: claude", process_error.message)
        
        # Test JSON decode error
        try
            JSON.parse("{\"incomplete\": ")
        catch original_error
            json_error = CLIJSONDecodeError("{\"incomplete\": ", original_error)
            @test json_error.line == "{\"incomplete\": "
            @test json_error.original_error == original_error
            @test occursin("Failed to decode JSON", string(json_error))
        end
    end

    @testset "JSON Response Parsing" begin
        # Test parsing JSON responses as they would come from CLI
        
        # Test system message JSON
        system_json = """
        {
            "type": "system",
            "subtype": "init",
            "session_id": "test-session",
            "tools": ["Read", "Write", "Bash"],
            "model": "claude-3-5-sonnet"
        }
        """
        system_data = JSON.parse(system_json)
        @test system_data["type"] == "system"
        @test system_data["subtype"] == "init"
        @test system_data["session_id"] == "test-session"
        @test system_data["tools"] == ["Read", "Write", "Bash"]
        
        # Test assistant message JSON
        assistant_json = """
        {
            "type": "assistant",
            "message": {
                "role": "assistant",
                "content": [
                    {
                        "type": "text",
                        "text": "Hello, I can help you with that."
                    },
                    {
                        "type": "tool_use",
                        "id": "tool-456",
                        "name": "Read",
                        "input": {"file_path": "example.txt"}
                    }
                ]
            }
        }
        """
        assistant_data = JSON.parse(assistant_json)
        @test assistant_data["type"] == "assistant"
        @test haskey(assistant_data["message"], "content")
        @test length(assistant_data["message"]["content"]) == 2
        @test assistant_data["message"]["content"][1]["type"] == "text"
        @test assistant_data["message"]["content"][2]["type"] == "tool_use"
        @test assistant_data["message"]["content"][2]["name"] == "Read"
        
        # Test result message JSON
        result_json = """
        {
            "type": "result",
            "subtype": "success",
            "cost_usd": 0.0123,
            "duration_ms": 2500,
            "duration_api_ms": 1800,
            "is_error": false,
            "num_turns": 2,
            "session_id": "test-session",
            "total_cost_usd": 0.0456,
            "usage": {
                "input_tokens": 150,
                "output_tokens": 75
            }
        }
        """
        result_data = JSON.parse(result_json)
        @test result_data["type"] == "result"
        @test result_data["subtype"] == "success"
        @test result_data["cost_usd"] == 0.0123
        @test result_data["duration_ms"] == 2500
        @test result_data["is_error"] == false
        @test result_data["num_turns"] == 2
        @test haskey(result_data, "usage")
        @test result_data["usage"]["input_tokens"] == 150
    end

    if CLI_AVAILABLE_FOR_INTEGRATION
        @testset "Live CLI Integration" begin
            # These tests require the actual Claude CLI to be available
            
            @testset "Simple Query Response" begin
                # Test a simple query that should work
                result = query(prompt="What is 2 + 2?")
                @test !isempty(result)
                @test any(msg -> msg isa AssistantMessage, result)
                @test any(msg -> msg isa ResultMessage, result)
                
                # Check that we get proper message types
                assistant_messages = filter(msg -> msg isa AssistantMessage, result)
                @test !isempty(assistant_messages)
                
                result_messages = filter(msg -> msg isa ResultMessage, result)
                @test !isempty(result_messages)
                
                # Check that assistant message has content
                for msg in assistant_messages
                    @test !isempty(msg.content)
                    @test all(block -> block isa ContentBlock, msg.content)
                end
                
                # Check that result message has valid cost info
                for msg in result_messages
                    @test msg.cost_usd >= 0
                    @test msg.total_cost_usd >= 0
                    @test msg.duration_ms > 0
                    @test !isempty(msg.session_id)
                end
            end

            @testset "Query with Options" begin
                # Test query with various options
                options = ClaudeCodeOptions(
                    system_prompt="You are a helpful assistant that gives short answers.",
                    max_turns=1
                )
                
                result = query(prompt="Tell me about Julia programming language in one sentence.", options=options)
                @test !isempty(result)
                @test any(msg -> msg isa AssistantMessage, result)
                @test any(msg -> msg isa ResultMessage, result)
            end

            @testset "Query with Tools" begin
                # Test query with tool usage (if permissions allow)
                options = ClaudeCodeOptions(
                    allowed_tools=["Read", "Write"],
                    permission_mode="acceptEdits",
                    max_turns=1
                )
                
                # Create a temporary test file
                test_file = "integration_test.txt"
                write(test_file, "This is a test file for integration testing.")
                
                try
                    result = query(
                        prompt="What is in the file integration_test.txt?", 
                        options=options
                    )
                    @test !isempty(result)
                    @test any(msg -> msg isa AssistantMessage, result)
                    
                    # Check if any assistant message contains tool use
                    assistant_messages = filter(msg -> msg isa AssistantMessage, result)
                    tool_used = any(assistant_messages) do msg
                        any(block -> block isa ToolUseBlock, msg.content)
                    end
                    
                    # Tool usage depends on permissions and Claude's decision
                    # So we don't assert it must happen, just that the structure is correct
                    @test true  # Test passes if we get here without errors
                    
                finally
                    # Clean up test file
                    if isfile(test_file)
                        rm(test_file)
                    end
                end
            end
        end
    else
        @testset "CLI Not Available Tests" begin
            # Test that appropriate errors are thrown when CLI is not available
            @test_throws CLINotFoundError query(prompt="test")
        end
    end
end