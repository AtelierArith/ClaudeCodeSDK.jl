"""
Tests for Claude SDK type definitions - ported from Python tests.
"""

using Test
using ClaudeCodeSDK

@testset "Message Types" begin
    @testset "UserMessage Creation" begin
        # Test creating a UserMessage
        msg = UserMessage("Hello, Claude!")
        @test msg.content == "Hello, Claude!"
    end

    @testset "AssistantMessage with Text" begin
        # Test creating an AssistantMessage with text content
        text_block = TextBlock("Hello, human!")
        msg = AssistantMessage([text_block])
        @test length(msg.content) == 1
        @test msg.content[1].text == "Hello, human!"
    end

    @testset "ToolUseBlock" begin
        # Test creating a ToolUseBlock
        block = ToolUseBlock(
            "tool-123", 
            "Read", 
            Dict("file_path" => "/test.txt")
        )
        @test block.id == "tool-123"
        @test block.name == "Read"
        @test block.input["file_path"] == "/test.txt"
    end

    @testset "ToolResultBlock" begin
        # Test creating a ToolResultBlock
        block = ToolResultBlock(
            "tool-123", 
            content="File contents here", 
            is_error=false
        )
        @test block.tool_use_id == "tool-123"
        @test block.content == "File contents here"
        @test block.is_error == false
    end

    @testset "ResultMessage" begin
        # Test creating a ResultMessage
        msg = ResultMessage(
            "success",
            0.01,
            1500,
            1200,
            false,
            1,
            "session-123",
            0.01
        )
        @test msg.subtype == "success"
        @test msg.cost_usd == 0.01
        @test msg.session_id == "session-123"
        @test msg.duration_ms == 1500
        @test msg.duration_api_ms == 1200
        @test msg.is_error == false
        @test msg.num_turns == 1
        @test msg.total_cost_usd == 0.01
    end
end

@testset "Options Configuration" begin
    @testset "Default Options" begin
        # Test Options with default values
        options = ClaudeCodeOptions()
        @test options.allowed_tools == String[]
        @test options.max_thinking_tokens == 8000
        @test isnothing(options.system_prompt)
        @test isnothing(options.permission_mode)
        @test options.continue_conversation == false
        @test options.disallowed_tools == String[]
    end

    @testset "Options with Tools" begin
        # Test Options with built-in tools
        options = ClaudeCodeOptions(
            allowed_tools=["Read", "Write", "Edit"], 
            disallowed_tools=["Bash"]
        )
        @test options.allowed_tools == ["Read", "Write", "Edit"]
        @test options.disallowed_tools == ["Bash"]
    end

    @testset "Options with Permission Mode" begin
        # Test Options with permission mode
        options = ClaudeCodeOptions(permission_mode="bypassPermissions")
        @test options.permission_mode == "bypassPermissions"
    end

    @testset "Options with System Prompt" begin
        # Test Options with system prompt
        options = ClaudeCodeOptions(
            system_prompt="You are a helpful assistant.",
            append_system_prompt="Be concise."
        )
        @test options.system_prompt == "You are a helpful assistant."
        @test options.append_system_prompt == "Be concise."
    end

    @testset "Options with Session Continuation" begin
        # Test Options with session continuation
        options = ClaudeCodeOptions(
            continue_conversation=true, 
            resume="session-123"
        )
        @test options.continue_conversation == true
        @test options.resume == "session-123"
    end

    @testset "Options with Model Specification" begin
        # Test Options with model specification
        options = ClaudeCodeOptions(
            model="claude-3-5-sonnet-20241022", 
            permission_prompt_tool_name="CustomTool"
        )
        @test options.model == "claude-3-5-sonnet-20241022"
        @test options.permission_prompt_tool_name == "CustomTool"
    end

    @testset "Options with MCP Configuration" begin
        # Test Options with MCP servers
        server_config = McpServerConfig(["stdio", "path/to/server"])
        options = ClaudeCodeOptions(
            mcp_servers=Dict("test_server" => server_config),
            mcp_tools=["custom_tool"]
        )
        @test haskey(options.mcp_servers, "test_server")
        @test options.mcp_servers["test_server"].transport == ["stdio", "path/to/server"]
        @test options.mcp_tools == ["custom_tool"]
    end

    @testset "Options with Working Directory" begin
        # Test Options with working directory
        options = ClaudeCodeOptions(cwd="/path/to/project")
        @test options.cwd == "/path/to/project"
    end
end

@testset "Content Block Union Type" begin
    @testset "TextBlock is ContentBlock" begin
        text_block = TextBlock("Hello")
        @test text_block isa ContentBlock
    end

    @testset "ToolUseBlock is ContentBlock" begin
        tool_block = ToolUseBlock("123", "Read", Dict("file" => "test.txt"))
        @test tool_block isa ContentBlock
    end

    @testset "ToolResultBlock is ContentBlock" begin
        result_block = ToolResultBlock("123")
        @test result_block isa ContentBlock
    end
end

@testset "Permission Mode Constants" begin
    @testset "Valid Permission Modes" begin
        @test "default" in ClaudeCodeSDK.PERMISSION_MODES
        @test "acceptEdits" in ClaudeCodeSDK.PERMISSION_MODES  
        @test "bypassPermissions" in ClaudeCodeSDK.PERMISSION_MODES
        @test length(ClaudeCodeSDK.PERMISSION_MODES) == 3
    end
end