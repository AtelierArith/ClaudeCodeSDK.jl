using Test
using ClaudeCodeSDK

# Skip tests if Claude Code CLI is not available
function check_cli_available_for_tests()
    try
        run(pipeline(`claude --version`, devnull))
        return true
    catch
        return false
    end
end

const CLI_AVAILABLE = check_cli_available_for_tests()

@testset "ClaudeCodeSDK.jl" begin
    # Core functionality tests (always run)
    @testset "Type Construction" begin
        # Test ClaudeCodeOptions construction
        options = ClaudeCodeOptions()
        @test options.allowed_tools == String[]
        @test options.max_thinking_tokens == 8000
        @test isnothing(options.system_prompt)
        
        # Test with custom options
        custom_options = ClaudeCodeOptions(
            system_prompt="You are a helpful assistant",
            max_turns=1,
            allowed_tools=["Read", "Write"]
        )
        @test custom_options.system_prompt == "You are a helpful assistant"
        @test custom_options.max_turns == 1
        @test custom_options.allowed_tools == ["Read", "Write"]
    end

    @testset "Message Types" begin
        # Test TextBlock
        text_block = TextBlock("Hello, World!")
        @test text_block.text == "Hello, World!"
        
        # Test ToolUseBlock
        tool_block = ToolUseBlock("123", "Read", Dict("file_path" => "test.txt"))
        @test tool_block.id == "123"
        @test tool_block.name == "Read"
        @test tool_block.input["file_path"] == "test.txt"
        
        # Test ToolResultBlock
        result_block = ToolResultBlock("123", content="File content", is_error=false)
        @test result_block.tool_use_id == "123"
        @test result_block.content == "File content"
        @test result_block.is_error == false
        
        # Test AssistantMessage
        assistant_msg = AssistantMessage([text_block, tool_block])
        @test length(assistant_msg.content) == 2
        @test assistant_msg.content[1] isa TextBlock
        @test assistant_msg.content[2] isa ToolUseBlock
    end

    @testset "Tool Functionality" begin
        # Test ReadTool
        read_tool = ReadTool("test.txt")
        @test read_tool.path == "test.txt"
        
        # Test WriteTool
        write_tool = WriteTool("output.txt", "Hello")
        @test write_tool.path == "output.txt"
        @test write_tool.content == "Hello"
        
        # Test BashTool
        bash_tool = BashTool("echo hello")
        @test bash_tool.command == "echo hello"
        
        # Test tool creation from block
        tool_block = ToolUseBlock("123", "Read", Dict("file_path" => "test.txt"))
        tool = create_tool_from_block(tool_block)
        @test tool isa ReadTool
        @test tool.path == "test.txt"
    end

    # Include all ported test files
    include("test_types.jl")
    include("test_errors.jl")
    include("test_client.jl")
    include("test_transport.jl")
    include("test_integration.jl")

    # CLI-dependent tests
    if CLI_AVAILABLE
        @testset "Basic Query (requires CLI)" begin
            # Test basic query functionality
            result = query(prompt="What is 2 + 2?")
            @test !isempty(result)
            @test any(m -> m isa AssistantMessage, result)
        end

        @testset "Options Query (requires CLI)" begin
            # Test query with options
            options = ClaudeCodeOptions(
                system_prompt="You are a helpful assistant",
                max_turns=1
            )
            result = query(prompt="Tell me a joke", options=options)
            @test !isempty(result)
            @test any(m -> m isa AssistantMessage, result)
        end

        @testset "Tools Query (requires CLI)" begin
            # Test tool usage
            options = ClaudeCodeOptions(
                allowed_tools=["Read", "Write", "Bash"],
                permission_mode="acceptEdits"
            )

            # Create temporary file
            test_file = "test_file.txt"
            write(test_file, "Hello, World!")

            try
                result = query(prompt="What is in the test_file.txt?", options=options)
                @test !isempty(result)
            finally
                # Remove temporary file
                if isfile(test_file)
                    rm(test_file)
                end
            end
        end
    else
        @testset "CLI Not Available" begin
            @test_throws CLINotFoundError query(prompt="Hello")
        end
    end
end