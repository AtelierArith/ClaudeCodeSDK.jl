#!/usr/bin/env julia
"""
Real-time streaming example that shows characters appearing as they're generated
"""

using ClaudeCodeSDK

println("=== Real-time Streaming Demo ===")
println("Watch the text appear character by character as Claude generates it!\n")

# Create a prompt that will generate a longer response
prompt = """
Write a detailed step-by-step recipe for making chocolate chip cookies. 
Include ingredients and instructions.
"""

println("Query: $(prompt)")
println("=" ^ 60)
println()

# Track timing
start_time = time()
first_char_time = nothing
char_count = 0

# Stream the response
for message in query_stream(prompt=prompt)
    if message isa AssistantMessage
        for block in message.content
            if block isa TextBlock
                # Print each character as it arrives
                for char in block.text
                    if first_char_time === nothing
                        first_char_time = time() - start_time
                        print("\n[First character after $(round(first_char_time, digits=2))s]\n\n")
                    end
                    
                    print(char)
                    flush(stdout)  # Force immediate display
                    char_count += 1
                    
                    # Optional: Add a tiny delay to make streaming more visible
                    # sleep(0.01)
                end
            end
        end
    elseif message isa ResultMessage
        total_time = time() - start_time
        println("\n\n" * ("=" ^ 60))
        println("📊 Streaming Statistics:")
        println("  • Time to first character: $(round(first_char_time, digits=2))s")
        println("  • Total time: $(round(total_time, digits=2))s")
        println("  • Characters streamed: $(char_count)")
        println("  • API duration: $(message.duration_api_ms)ms")
        println("  • Cost: \$$(round(message.cost_usd, digits=4))")
    end
end