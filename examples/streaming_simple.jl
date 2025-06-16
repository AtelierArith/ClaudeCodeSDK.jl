#!/usr/bin/env julia
"""
Simple streaming example showing the difference between batch and streaming modes
"""

using ClaudeCodeSDK

# BATCH MODE - waits for complete response
println("=== BATCH MODE (query) ===")
println("Waiting for complete response...")

for message in query(prompt="Write a short story about a robot in 3 sentences")
    if message isa AssistantMessage
        for block in message.content
            if block isa TextBlock
                println(block.text)
            end
        end
    end
end

println("\n=== STREAMING MODE (query_stream) ===") 
println("Output appears as it's generated...")

# STREAMING MODE - outputs as it arrives
for message in query_stream(prompt="Write a short story about a robot in 3 sentences")
    if message isa AssistantMessage
        for block in message.content
            if block isa TextBlock
                print(block.text)
                flush(stdout)  # Important: flush to see output immediately
            end
        end
    end
end

println("\n\nDone!")