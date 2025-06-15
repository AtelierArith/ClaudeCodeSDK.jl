# ClaudeCodeSDK.jl

A comprehensive Julia port of the Claude Code SDK that provides a native Julia interface for interacting with Claude Code CLI. This implementation closely mirrors the official Python SDK architecture while leveraging Julia's strengths in type safety and performance.

## Status

✅ **Fully functional** - Complete feature parity with Python SDK. All core features implemented, tested, and working.

## Features

✅ **Complete Implementation:**
- **Keyword Argument API**: `query(prompt="...", options=...)` matching Python SDK
- **Advanced Configuration**: All 14 `ClaudeCodeOptions` fields including MCP support
- **Robust CLI Integration**: Complete command building with all CLI options
- **Type Safety**: Full Julia type annotations throughout
- **Tool Execution**: Read, Write, Bash tools with proper result handling
- **Message Parsing**: Complete support for all message types
- **JSON Streaming**: Real-time response parsing from CLI
- **Error Handling**: Comprehensive exception hierarchy
- **Cost Tracking**: Usage and cost information from queries
- **Environment Management**: Working directory and environment variable support
- **MCP Support**: Model Context Protocol servers and tools

✅ **Python SDK Compatibility:**
- Same API patterns and functionality
- Equivalent configuration options
- Matching error handling
- Similar message structure

## Installation

This package is currently in development. To use it:

```bash
# Clone the repository
git clone <repository-url>
cd ClaudeCodeSDK.jl

# Install dependencies
julia --project -e "using Pkg; Pkg.instantiate()"
```

**Prerequisites:**
- Julia 1.10+
- Node.js to install Claude Code CLI: `npm install -g @anthropic-ai/claude-code`

## Quick Start

```julia
using ClaudeCodeSDK

# Basic query (new keyword argument API)
for message in query(prompt="What is 2 + 2?")
    if message isa AssistantMessage
        for block in message.content
            if block isa TextBlock
                println(block.text)  # Output: 4
            end
        end
    end
end

# With configuration options
options = ClaudeCodeOptions(
    system_prompt="You are a helpful assistant that explains things simply.",
    max_turns=1
)

for message in query(prompt="Explain what Julia is in one sentence.", options=options)
    if message isa AssistantMessage
        for block in message.content
            if block isa TextBlock
                println(block.text)
            end
        end
    end
end

# Using tools
options = ClaudeCodeOptions(
    allowed_tools=["Read", "Write"],
    permission_mode="acceptEdits"
)

for message in query(
    prompt="Create a file called hello.txt with 'Hello, World!' in it",
    options=options
)
    if message isa AssistantMessage
        for block in message.content
            if block isa TextBlock
                println(block.text)
            end
        end
    elseif message isa ResultMessage
        println("Cost: \$$(round(message.cost_usd, digits=4))")
    end
end
```

## Next Steps

- [Getting Started Guide](getting-started.md)
- [API Reference](api.md)
- [Examples](examples.md)
- [Architecture Overview](architecture.md)