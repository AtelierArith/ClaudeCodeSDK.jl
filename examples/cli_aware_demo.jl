using ClaudeCodeSDK

println("Claude Code SDK CLI-Aware Demo")
println("=" ^ 40)

# Check if CLI is available
function check_claude_cli()
    try
        run(pipeline(`claude --version`, devnull))
        return true
    catch
        return false
    end
end

if check_claude_cli()
    println("✓ Claude Code CLI detected - running full demo")
    
    # Basic usage example
    println("\n1. Basic Query:")
    try
        for message in query("What is 2 + 2?")
            if message isa AssistantMessage
                for block in message.content
                    if block isa TextBlock
                        println("   Response: $(block.text)")
                    end
                end
            end
        end
    catch e
        println("   Error: $e")
    end

    # Example with options
    println("\n2. Query with Options:")
    options = ClaudeCodeOptions(
        system_prompt="You are a helpful assistant",
        max_turns=1
    )

    try
        for message in query("Tell me a short joke", options=options)
            if message isa AssistantMessage
                for block in message.content
                    if block isa TextBlock
                        println("   Joke: $(block.text)")
                    end
                end
            end
        end
    catch e
        println("   Error: $e")
    end

    # Tool usage example
    println("\n3. Query with Tools:")
    options = ClaudeCodeOptions(
        allowed_tools=["Read", "Write", "Bash"],
        permission_mode="acceptEdits"
    )

    try
        for message in query("Create a simple hello.jl file with println", options=options)
            if message isa AssistantMessage
                for block in message.content
                    if block isa TextBlock
                        println("   Text: $(block.text)")
                    elseif block isa ToolUseBlock
                        println("   Using tool: $(block.name)")
                        println("   Arguments: $(block.input)")
                    elseif block isa ToolResultBlock
                        println("   Tool result: $(block.content)")
                    end
                end
            end
        end
    catch e
        println("   Error: $e")
    end

else
    println("⚠ Claude Code CLI not found")
    println("\nTo install Claude Code CLI:")
    println("  npm install -g @anthropic-ai/claude-code")
    
    println("\nDemonstrating SDK components without CLI:")
    
    # Show that the SDK components work
    options = ClaudeCodeOptions(
        system_prompt="You are a helpful assistant",
        max_turns=1,
        allowed_tools=["Read", "Write", "Bash"]
    )
    
    println("   ✓ Created ClaudeCodeOptions")
    println("   ✓ System prompt: $(options.system_prompt)")
    println("   ✓ Allowed tools: $(join(options.allowed_tools, ", "))")
    
    # Test message construction
    text_block = TextBlock("Hello from Julia!")
    tool_block = ToolUseBlock("123", "Read", Dict("file_path" => "test.txt"))
    message = AssistantMessage([text_block, tool_block])
    
    println("   ✓ Created AssistantMessage with $(length(message.content)) blocks")
    
    # Show error handling
    try
        query("Hello")
    catch e
        if e isa CLINotFoundError
            println("   ✓ Proper error handling: $(typeof(e))")
        end
    end
end

println("\n" * "=" ^ 40)
println("Demo completed!")