# Examples

This page contains various usage examples for ClaudeCodeSDK.jl.

## Basic Examples

### Simple Query

```julia
using ClaudeCodeSDK

# Basic query
result = query("What is 2 + 2?")
for message in result
    if message isa AssistantMessage
        for block in message.content
            if block isa TextBlock
                println("Claude says: $(block.text)")
            end
        end
    end
end
```

### Query with System Prompt

```julia
using ClaudeCodeSDK

# Configure with system prompt
options = ClaudeCodeOptions(
    system_prompt="You are a helpful math tutor. Explain your reasoning step by step."
)

result = query("How do you solve 2x + 5 = 13?", options=options)
for message in result
    if message isa AssistantMessage
        for block in message.content
            if block isa TextBlock
                println(block.text)
            end
        end
    end
end
```

## Configuration Examples

### Working Directory

```julia
using ClaudeCodeSDK

# Set working directory for file operations
options = ClaudeCodeOptions(
    cwd="/path/to/my/project",
    allowed_tools=["Read", "Write"]
)

result = query("List the files in the current directory", options=options)
```

### Model Selection

```julia
using ClaudeCodeSDK

# Use specific Claude model
options = ClaudeCodeOptions(
    model="claude-3-5-sonnet-20241022"
)

result = query("Write a haiku about programming", options=options)
```

### Permission Modes

```julia
using ClaudeCodeSDK

# Auto-accept file edits
options = ClaudeCodeOptions(
    allowed_tools=["Read", "Write", "Bash"],
    permission_mode="acceptEdits"
)

result = query("Create a hello.jl file with a simple greeting", options=options)
```

## Advanced Examples

### Multiple Turn Conversation

```julia
using ClaudeCodeSDK

# Configure for multi-turn conversation
options = ClaudeCodeOptions(
    max_turns=5,
    system_prompt="You are a coding assistant helping with Julia programming."
)

# First query
result1 = query("Help me write a function to calculate fibonacci numbers", options=options)

# Process response and continue conversation
# Note: Currently each query is independent - conversation state is maintained by Claude CLI
result2 = query("Can you optimize that fibonacci function?", options=options)
```

### Tool Usage with Error Handling

```julia
using ClaudeCodeSDK

# Configure tools and error handling
options = ClaudeCodeOptions(
    allowed_tools=["Read", "Write", "Bash"],
    cwd=pwd()
)

try
    result = query("Read the contents of README.md and summarize it", options=options)
    
    for message in result
        if message isa AssistantMessage
            for block in message.content
                if block isa TextBlock
                    println("Summary: $(block.text)")
                elseif block isa ToolUseBlock
                    println("Tool used: $(block.name) with input: $(block.input)")
                elseif block isa ToolResultBlock
                    println("Tool result: $(block.content)")
                end
            end
        end
    end
    
catch e
    if e isa CLINotFoundError
        println("Error: Claude CLI not found. Install with: npm install -g @anthropic-ai/claude-code")
    elseif e isa ProcessError
        println("Error: Process failed with exit code $(e.exit_code)")
        println("Output: $(e.output)")
    else
        println("Unexpected error: $e")
    end
end
```

### Development Assistant

```julia
using ClaudeCodeSDK

# Configure as development assistant
options = ClaudeCodeOptions(
    system_prompt="You are a Julia development assistant. Help with code review, debugging, and optimization.",
    allowed_tools=["Read", "Write", "Bash"],
    cwd=pwd(),
    max_turns=10
)

# Ask for code review
result = query("Please review the code in src/ClaudeCodeSDK.jl and suggest improvements", options=options)

for message in result
    if message isa AssistantMessage
        for block in message.content
            if block isa TextBlock
                println("Review: $(block.text)")
            end
        end
    end
end
```

## Testing Examples

### CLI Availability Check

```julia
using ClaudeCodeSDK

# Check if CLI is available before making requests
function is_cli_available()
    try
        # Simple test query
        result = query("test")
        return true
    catch e
        if e isa CLINotFoundError
            return false
        else
            rethrow(e)
        end
    end
end

if is_cli_available()
    println("Claude CLI is available")
    result = query("Hello Claude!")
else
    println("Claude CLI not found. Please install it first.")
end
```

### Mock Testing (Without CLI)

```julia
using ClaudeCodeSDK

# Example of testing SDK components without CLI
function test_message_parsing()
    # Create test message
    text_block = TextBlock("Hello from Claude")
    assistant_msg = AssistantMessage([text_block])
    
    # Test message structure
    @assert assistant_msg isa AssistantMessage
    @assert length(assistant_msg.content) == 1
    @assert assistant_msg.content[1] isa TextBlock
    @assert assistant_msg.content[1].text == "Hello from Claude"
    
    println("Message parsing test passed!")
end

test_message_parsing()
```

## Integration Examples

### Project Analysis

```julia
using ClaudeCodeSDK

# Analyze a Julia project
options = ClaudeCodeOptions(
    system_prompt="You are a Julia code analyst. Analyze project structure and provide insights.",
    allowed_tools=["Read", "Bash"],
    cwd="/path/to/julia/project"
)

queries = [
    "Analyze the Project.toml file and list the dependencies",
    "Read the main module file and describe its architecture",
    "Run the tests and report any issues"
]

for query_text in queries
    println("\\n=== $query_text ===")
    try
        result = query(query_text, options=options)
        for message in result
            if message isa AssistantMessage
                for block in message.content
                    if block isa TextBlock
                        println(block.text)
                    end
                end
            end
        end
    catch e
        println("Error with query '$query_text': $e")
    end
end
```

### Documentation Generation

```julia
using ClaudeCodeSDK

# Generate documentation
options = ClaudeCodeOptions(
    system_prompt="You are a documentation generator for Julia packages.",
    allowed_tools=["Read", "Write"],
    cwd=pwd()
)

result = query("Read the source files and generate API documentation in Markdown format", options=options)

for message in result
    if message isa AssistantMessage
        for block in message.content
            if block isa TextBlock
                println("Documentation generated:")
                println(block.text)
            end
        end
    end
end
```

## Running the Example Files

The repository includes several example files you can run directly:

```bash
# Basic usage example
julia --project examples/quick_start.jl

# Tool execution without CLI
julia --project examples/tool_execution_demo.jl

# CLI-aware functionality
julia --project examples/cli_aware_demo.jl
```

Each example file demonstrates different aspects of the SDK and includes comprehensive error handling and output formatting.