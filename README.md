# ClaudeCodeSDK.jl

Julia SDK for Claude Code. See the [Claude Code SDK documentation](https://docs.anthropic.com/en/docs/claude-code/sdk) for more information.

## Installation

```julia
using Pkg
Pkg.add("ClaudeCodeSDK")
```

**Prerequisites:**
- Julia 1.6+
- Node.js
- Claude Code: `npm install -g @anthropic-ai/claude-code`

## Quick Start

```julia
using ClaudeCodeSDK

# Basic query
for message in query("What is 2 + 2?")
    if message isa AssistantMessage
        for block in message.content
            if block isa TextBlock
                println(block.text)
            end
        end
    end
end

# With options
options = ClaudeCodeOptions(
    system_prompt="You are a helpful assistant",
    max_turns=1
)

for message in query("Tell me a joke", options=options)
    println(message)
end
```

## Usage

### Basic Query

```julia
using ClaudeCodeSDK

# Simple query
for message in query("Hello Claude")
    if message isa AssistantMessage
        for block in message.content
            if block isa TextBlock
                println(block.text)
            end
        end
    end
end

# With options
options = ClaudeCodeOptions(
    system_prompt="You are a helpful assistant",
    max_turns=1
)

for message in query("Tell me a joke", options=options)
    println(message)
end
```

### Using Tools

```julia
options = ClaudeCodeOptions(
    allowed_tools=["Read", "Write", "Bash"],
    permission_mode="acceptEdits"  # auto-accept file edits
)

for message in query("Create a hello.jl file", options=options)
    if message isa AssistantMessage
        for block in message.content
            if block isa TextBlock
                println(block.text)
            elseif block isa ToolUseBlock
                println("Using tool: $(block.tool)")
                println("Arguments: $(block.args)")
            elseif block isa ToolResultBlock
                println("Tool result: $(block.result)")
            end
        end
    end
end
```

### Working Directory

```julia
options = ClaudeCodeOptions(
    cwd="/path/to/project"
)
```

## API Reference

### `query(prompt::String; options::Union{ClaudeCodeOptions, Nothing}=nothing)`

Main function for querying Claude.

**Parameters:**
- `prompt::String`: The prompt to send to Claude
- `options::Union{ClaudeCodeOptions, Nothing}`: Optional configuration

**Returns:** Iterator of response messages

### Types

See [src/types.jl](src/types.jl) for complete type definitions:
- `ClaudeCodeOptions` - Configuration options
- `AssistantMessage`, `UserMessage`, `SystemMessage`, `ResultMessage` - Message types
- `TextBlock`, `ToolUseBlock`, `ToolResultBlock` - Content blocks

## Error Handling

```julia
using ClaudeCodeSDK

try
    for message in query("Hello")
        println(message)
    end
catch e
    if e isa CLINotFoundError
        println("Please install Claude Code")
    elseif e isa ProcessError
        println("Process failed with exit code: $(e.exit_code)")
    elseif e isa CLIJSONDecodeError
        println("Failed to parse response: $e")
    end
end
```

See [src/errors.jl](src/errors.jl) for all error types.

## Available Tools

See the [Claude Code documentation](https://docs.anthropic.com/en/docs/claude-code/security#tools-available-to-claude) for a complete list of available tools.

## Examples

See [examples/quick_start.jl](examples/quick_start.jl) for a complete working example.

## License

MIT