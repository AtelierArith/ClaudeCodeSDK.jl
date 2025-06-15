#!/usr/bin/env julia
"""
JSON Streaming Demo for Claude Code SDK in Julia

This example demonstrates how the ClaudeCodeSDK.jl processes JSON streaming 
from the Claude CLI. While the current implementation processes messages in 
batch for simplicity and reliability, this shows the underlying streaming 
JSON format and how messages are parsed.
"""

using ClaudeCodeSDK
using JSON

function streaming_demo()
    """Demonstrate JSON streaming processing."""
    println("=== JSON Streaming Demo ===")
    println("This shows how Claude CLI outputs streaming JSON and how we process it.")
    println()

    # Example with a longer response that shows multiple JSON messages
    options = ClaudeCodeOptions(
        system_prompt="You are a helpful assistant. Provide detailed explanations.",
        max_turns=1
    )

    println("Query: Explain the concept of JSON streaming in 2-3 sentences.")
    println("Processing streaming JSON messages...")
    println()

    # Track timing and message flow
    start_time = time()
    message_count = 0

    for message in query(
        prompt="Explain the concept of JSON streaming in 2-3 sentences.",
        options=options
    )
        message_count += 1
        elapsed = round(time() - start_time, digits=2)
        
        println("📨 Message $message_count (t+$(elapsed)s): $(typeof(message))")
        
        if message isa SystemMessage
            println("   └─ System initialization: $(message.subtype)")
            if haskey(message.data, "session_id")
                println("   └─ Session ID: $(message.data["session_id"])")
            end
            if haskey(message.data, "tools")
                println("   └─ Available tools: $(length(message.data["tools"])) tools")
            end
            
        elseif message isa AssistantMessage
            println("   └─ Assistant response with $(length(message.content)) content blocks:")
            for (i, block) in enumerate(message.content)
                if block isa TextBlock
                    # Show first 100 chars of text
                    preview = length(block.text) > 100 ? block.text[1:100] * "..." : block.text
                    println("      $i. TextBlock: \"$preview\"")
                elseif block isa ToolUseBlock
                    println("      $i. ToolUseBlock: $(block.name) (ID: $(block.id))")
                elseif block isa ToolResultBlock
                    println("      $i. ToolResultBlock: $(block.tool_use_id)")
                end
            end
            
        elseif message isa ResultMessage
            println("   └─ Query result:")
            println("      • Duration: $(message.duration_ms)ms (API: $(message.duration_api_ms)ms)")
            println("      • Cost: \$$(round(message.cost_usd, digits=4))")
            println("      • Total cost: \$$(round(message.total_cost_usd, digits=4))")
            println("      • Turns: $(message.num_turns)")
            if message.usage !== nothing
                println("      • Tokens: $(get(message.usage, "input_tokens", 0)) input, $(get(message.usage, "output_tokens", 0)) output")
            end
        end
        println()
    end

    total_time = round(time() - start_time, digits=2)
    println("✅ Processed $message_count messages in $(total_time)s")
    println()
end

function raw_cli_demo()
    """Demonstrate the raw CLI JSON streaming format."""
    println("=== Raw CLI JSON Streaming Format ===")
    println("This shows what the raw CLI output looks like with --output-format stream-json")
    println()

    # Show what the CLI command looks like
    println("CLI Command:")
    println("claude --output-format stream-json --verbose --print \"What is 2+2?\"")
    println()
    
    println("Raw JSON Stream Output:")
    println("(Each line is a separate JSON message)")
    println()
    
    # Simulate the JSON streaming format that comes from CLI
    sample_messages = [
        Dict(
            "type" => "system",
            "subtype" => "init",
            "cwd" => "/current/directory",
            "session_id" => "example-session-123",
            "tools" => ["Read", "Write", "Bash"],
            "model" => "claude-sonnet-4-20250514"
        ),
        Dict(
            "type" => "assistant",
            "message" => Dict(
                "id" => "msg_123",
                "content" => [
                    Dict("type" => "text", "text" => "4")
                ]
            ),
            "session_id" => "example-session-123"
        ),
        Dict(
            "type" => "result",
            "subtype" => "success",
            "is_error" => false,
            "duration_ms" => 1250,
            "duration_api_ms" => 800,
            "num_turns" => 1,
            "session_id" => "example-session-123",
            "total_cost_usd" => 0.0156,
            "usage" => Dict(
                "input_tokens" => 8,
                "output_tokens" => 3
            )
        )
    ]

    for (i, msg) in enumerate(sample_messages)
        println("Message $i:")
        println(JSON.json(msg, 2))  # Pretty print with indentation
        println()
    end
end

function message_flow_demo()
    """Demonstrate message flow and processing."""
    println("=== Message Flow Processing Demo ===")
    println("This shows how different types of messages flow through the system.")
    println()

    # Example with tool usage to show more complex message flow
    options = ClaudeCodeOptions(
        allowed_tools=["Read", "Write"],
        permission_mode="acceptEdits",
        system_prompt="You are a helpful file assistant."
    )

    println("Query: Create a small test file with current timestamp")
    println("(This will show tool usage in the message stream)")
    println()

    messages_by_type = Dict{String, Vector{Any}}()

    for message in query(
        prompt="Create a file called timestamp.txt with the current date and time",
        options=options
    )
        msg_type = string(typeof(message))
        if !haskey(messages_by_type, msg_type)
            messages_by_type[msg_type] = []
        end
        push!(messages_by_type[msg_type], message)
        
        # Show real-time processing
        print("📨 $(typeof(message)) ")
        if message isa AssistantMessage
            tool_count = count(block -> block isa ToolUseBlock, message.content)
            if tool_count > 0
                print("(with $tool_count tool use(s)) ")
            end
        elseif message isa ResultMessage
            print("(\$$(round(message.cost_usd, digits=4))) ")
        end
        println()
    end

    println("\n📊 Message Summary:")
    for (msg_type, messages) in messages_by_type
        println("   • $msg_type: $(length(messages)) message(s)")
    end
    println()
end

function main()
    """Run all streaming demos."""
    try
        streaming_demo()
        raw_cli_demo()
        message_flow_demo()
        
        println("🎉 All streaming demos completed successfully!")
        println()
        println("💡 Key Points:")
        println("   • The CLI outputs one JSON message per line")
        println("   • Our SDK processes these in batch for reliability")
        println("   • Each message type provides different information")
        println("   • Tool usage creates additional message flows")
        println("   • Cost and timing information is available in ResultMessage")
        
    catch e
        if e isa CLINotFoundError
            println("❌ Claude CLI not found. Install with:")
            println("   npm install -g @anthropic-ai/claude-code")
        elseif e isa CLIConnectionError
            println("❌ Connection error: $(e.message)")
        elseif e isa ProcessError
            println("❌ Process error: $(e.message)")
            if e.exit_code !== nothing
                println("   Exit code: $(e.exit_code)")
            end
        else
            println("❌ Unexpected error: $e")
        end
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end