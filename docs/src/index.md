# ClaudeCodeSDK.jl

A Julia port of the Claude Code SDK, providing a native Julia interface for interacting with Claude Code CLI. This implementation closely mirrors the Python SDK architecture while following Julia conventions and patterns.

## Status

**Core functionality complete and working.** Basic queries and options handling fully functional with the Claude CLI.

## Features

✅ **Working Features:**
- Basic Claude queries with text responses
- Configuration options (`ClaudeCodeOptions`)
- CLI process management and communication
- Message type system and parsing
- Error handling with proper exceptions
- Tool type definitions and local execution

⚠️ **Known Limitations:**
- Tool usage with Claude CLI needs CLI interface refinement
- Streaming JSON responses not yet implemented
- Some advanced Claude CLI options not yet supported

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
```

## Next Steps

- [Getting Started Guide](getting-started.md)
- [API Reference](api.md)
- [Examples](examples.md)
- [Architecture Overview](architecture.md)