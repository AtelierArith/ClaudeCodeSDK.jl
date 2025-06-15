#!/usr/bin/env julia
"""
Quick start example for Claude Code SDK in Julia
"""

using ClaudeCodeSDK

function basic_example()
    """Basic example - simple question."""
    println("=== Basic Example ===")

    for message in query(prompt="What is 2 + 2?")
        if message isa AssistantMessage
            for block in message.content
                if block isa TextBlock
                    println("Claude: $(block.text)")
                end
            end
        end
    end
    println()
end

function with_options_example()
    """Example with custom options."""
    println("=== With Options Example ===")

    options = ClaudeCodeOptions(
        system_prompt="You are a helpful assistant that explains things simply.",
        max_turns=1
    )

    for message in query(
        prompt="Explain what Julia is in one sentence.",
        options=options
    )
        if message isa AssistantMessage
            for block in message.content
                if block isa TextBlock
                    println("Claude: $(block.text)")
                end
            end
        end
    end
    println()
end

function with_tools_example()
    """Example using tools."""
    println("=== With Tools Example ===")

    options = ClaudeCodeOptions(
        allowed_tools=["Read", "Write"],
        system_prompt="You are a helpful file assistant."
    )

    for message in query(
        prompt="Create a file called hello.txt with 'Hello, World!' in it",
        options=options
    )
        if message isa AssistantMessage
            for block in message.content
                if block isa TextBlock
                    println("Claude: $(block.text)")
                end
            end
        elseif message isa ResultMessage && message.cost_usd > 0
            println("\nCost: \$$(round(message.cost_usd, digits=4))")
        end
    end
    println()
end

function main()
    """Run all examples."""
    basic_example()
    with_options_example()
    with_tools_example()
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end