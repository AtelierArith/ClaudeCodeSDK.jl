#!/usr/bin/env julia
"""
Real-time Streaming Demo for Claude Code SDK in Julia

This example demonstrates how to get real-time streaming output from Claude,
where messages are displayed as they arrive from the CLI.
"""

using ClaudeCodeSDK

function realtime_streaming_demo()
    """Demonstrate real-time streaming output."""
    println("=== Real-time Streaming Demo ===")
    println("Watch as Claude's response streams in real-time!")
    println()

    # Example 1: Simple streaming
    println("1. Simple streaming example:")
    println("Query: Write a haiku about Julia programming")
    println("-" * 40)
    
    for message in query_stream(prompt="Write a haiku about Julia programming")
        if message isa AssistantMessage
            for block in message.content
                if block isa TextBlock
                    print(block.text)
                    flush(stdout)  # Force immediate output
                end
            end
        end
    end
    println("\n" * "-" * 40)
    
    # Example 2: Streaming with timing information
    println("\n2. Streaming with timing information:")
    println("Query: Explain the concept of multiple dispatch in 3 sentences")
    println("-" * 40)
    
    start_time = time()
    
    for message in query_stream(
        prompt="Explain the concept of multiple dispatch in 3 sentences",
        options=ClaudeCodeOptions(
            system_prompt="You are a concise technical writer"
        )
    )
        elapsed = round(time() - start_time, digits=2)
        
        if message isa SystemMessage
            println("[$(elapsed)s] System initialized: $(message.subtype)")
            
        elseif message isa AssistantMessage
            print("[$(elapsed)s] Assistant: ")
            for block in message.content
                if block isa TextBlock
                    print(block.text)
                    flush(stdout)
                end
            end
            
        elseif message isa ResultMessage
            println("\n[$(elapsed)s] Complete!")
            println("  • Duration: $(message.duration_ms)ms")
            println("  • Cost: \$$(round(message.cost_usd, digits=4))")
        end
    end
    println("-" * 40)
    
    # Example 3: Interactive streaming with visual feedback
    println("\n3. Interactive streaming with visual feedback:")
    println("Query: Count from 1 to 10 slowly")
    println("-" * 40)
    
    char_count = 0
    
    for message in query_stream(prompt="Count from 1 to 10 slowly, with each number on a new line")
        if message isa AssistantMessage
            for block in message.content
                if block isa TextBlock
                    # Show character-by-character streaming effect
                    for char in block.text
                        print(char)
                        flush(stdout)
                        char_count += 1
                        
                        # Add visual feedback every 10 characters
                        if char_count % 10 == 0
                            print(" 📝")
                            flush(stdout)
                        end
                    end
                end
            end
        elseif message isa ResultMessage
            println("\n✅ Streaming complete! ($(char_count) characters)")
        end
    end
    println("-" * 40)
end

function streaming_with_tools_demo()
    """Demonstrate streaming with tool usage."""
    println("\n=== Streaming with Tools Demo ===")
    println("This shows real-time streaming when Claude uses tools")
    println()
    
    options = ClaudeCodeOptions(
        allowed_tools=["Read", "Write"],
        permission_mode="acceptEdits"
    )
    
    println("Query: Create a file called stream_test.txt with a timestamp")
    println("-" * 40)
    
    for message in query_stream(
        prompt="Create a file called stream_test.txt with the current timestamp",
        options=options
    )
        if message isa SystemMessage
            println("🔧 System: $(message.subtype)")
            
        elseif message isa AssistantMessage
            for block in message.content
                if block isa TextBlock
                    print("💬 ")
                    print(block.text)
                    flush(stdout)
                elseif block isa ToolUseBlock
                    println("\n🛠️  Using tool: $(block.name)")
                    println("   ID: $(block.id)")
                elseif block isa ToolResultBlock
                    println("✅ Tool result received")
                end
            end
            
        elseif message isa ResultMessage
            println("\n📊 Summary:")
            println("   • Success: $(!(message.is_error))")
            println("   • Duration: $(message.duration_ms)ms")
            println("   • Cost: \$$(round(message.cost_usd, digits=4))")
        end
    end
    println("-" * 40)
end

function compare_streaming_modes()
    """Compare batch vs streaming modes."""
    println("\n=== Batch vs Streaming Comparison ===")
    println()
    
    test_prompt = "List 5 benefits of Julia programming language"
    
    # Batch mode (original query function)
    println("1. BATCH MODE (query):")
    println("   All messages received at once after completion")
    println("-" * 40)
    
    batch_start = time()
    messages = query(prompt=test_prompt)
    batch_time = round(time() - batch_start, digits=2)
    
    println("⏱️  Total time until first output: $(batch_time)s")
    for message in messages
        if message isa AssistantMessage
            for block in message.content
                if block isa TextBlock
                    println(block.text)
                end
            end
        end
    end
    
    println("\n2. STREAMING MODE (query_stream):")
    println("   Messages received as they arrive")
    println("-" * 40)
    
    stream_start = time()
    first_output_time = nothing
    
    for message in query_stream(prompt=test_prompt)
        if message isa AssistantMessage && first_output_time === nothing
            first_output_time = round(time() - stream_start, digits=2)
            println("⏱️  Time to first output: $(first_output_time)s")
        end
        
        if message isa AssistantMessage
            for block in message.content
                if block isa TextBlock
                    print(block.text)
                    flush(stdout)
                end
            end
        end
    end
    
    println("\n\n📊 Comparison:")
    println("   • Batch mode: Wait $(batch_time)s for complete response")
    println("   • Stream mode: First output in $(first_output_time)s")
    println("   • Streaming advantage: Start reading $(round(batch_time - first_output_time, digits=2))s earlier!")
end

function main()
    """Run all streaming demos."""
    try
        realtime_streaming_demo()
        streaming_with_tools_demo()
        compare_streaming_modes()
        
        println("\n🎉 All real-time streaming demos completed!")
        println()
        println("💡 Key Takeaways:")
        println("   • Use query_stream() for real-time output")
        println("   • Messages arrive as Claude generates them")
        println("   • Always use flush(stdout) for immediate display")
        println("   • Streaming is great for long responses")
        println("   • You can process messages while Claude is still thinking!")
        
    catch e
        if e isa CLINotFoundError
            println("❌ Claude CLI not found. Install with:")
            println("   npm install -g @anthropic-ai/claude-code")
        elseif e isa CLIConnectionError
            println("❌ Connection error: $(e.message)")
        else
            println("❌ Error: $e")
            println(stacktrace())
        end
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end