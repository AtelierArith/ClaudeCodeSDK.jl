using ClaudeCodeSDK

# Basic usage example
for message in query("What is 2 + 2?")
    if message isa AssistantMessage
        for block in message.content
            if block isa TextBlock
                println(block.text)
            end
        end
    end
end

# Example with options
options = ClaudeCodeOptions(
    system_prompt="You are a helpful assistant",
    max_turns=1
)

for message in query("Tell me a joke", options=options)
    if message isa AssistantMessage
        for block in message.content
            if block isa TextBlock
                println(block.text)
            end
        end
    end
end

# Tool usage example (currently has CLI limitations)
println("\n# Tool Usage Example (temporarily disabled due to CLI interface limitations)")
println("# This would work:")
println("# options = ClaudeCodeOptions(allowed_tools=[\"Read\", \"Write\", \"Bash\"])")
println("# query(\"Create a hello.jl file\", options=options)")

# Instead, let's show a simple non-tool query
println("\nDemonstrating simple query without tools:")
for message in query("What is the capital of France?")
    if message isa AssistantMessage
        for block in message.content
            if block isa TextBlock
                println("Answer: $(block.text)")
            end
        end
    end
end