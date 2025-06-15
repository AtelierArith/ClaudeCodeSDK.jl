# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Julia Development Commands

### Testing

If you modify any source code, please run the following testing protocols:

```bash
# Run all tests (288 tests total)
julia --project -e "using Pkg; Pkg.test()"

# Run specific test files
julia --project test/test_types.jl
julia --project test/test_errors.jl
julia --project test/test_client.jl
julia --project test/test_transport.jl
julia --project test/test_integration.jl
```

### Example Usage
```bash
# Run example files
julia --project examples/quick_start.jl
julia --project examples/streaming_demo.jl
julia --project examples/tool_execution_demo.jl
julia --project examples/cli_aware_demo.jl
```

## Architecture Overview

This is an **unofficial** Julia SDK for Claude Code that **fully mirrors** the Python SDK architecture and functionality. The implementation is complete and provides the same capabilities as the official Python SDK while leveraging Julia's type safety and performance.

### Core Components

1. **Main Entry Point** (`src/ClaudeCodeSDK.jl`):
   - Exports `query(; prompt, options)` function with keyword arguments matching Python SDK
   - Manages `InternalClient` and sets environment variables

2. **Type System** (`src/types.jl`):
   - Complete type definitions matching Python SDK structure
   - `ClaudeCodeOptions` with all 14 configuration fields
   - Message types: `AssistantMessage`, `UserMessage`, `SystemMessage`, `ResultMessage`
   - Content blocks: `TextBlock`, `ToolUseBlock`, `ToolResultBlock`
   - MCP support: `McpServerConfig`

3. **Client Layer** (`src/internal/client.jl`):
   - `InternalClient` orchestrates queries and parses responses
   - Message parsing from CLI JSON output into typed structures

4. **Transport Layer** (`src/internal/cli.jl`):
   - `SubprocessCLITransport` handles CLI communication
   - Comprehensive CLI discovery and command building
   - JSON streaming support with line-by-line parsing
   - Robust process management

5. **Error Handling** (`src/errors.jl`):
   - Complete exception hierarchy matching Python SDK
   - `ClaudeSDKError`, `CLINotFoundError`, `CLIConnectionError`, `ProcessError`, `CLIJSONDecodeError`

6. **Tool System** (`src/internal/tools.jl`): Local tool execution functionality

### Key Features Implemented

✅ **Complete Python SDK Compatibility:**
- **API**: Keyword argument API `query(prompt="...", options=...)`
- **Configuration**: All 14 `ClaudeCodeOptions` fields supported
- **CLI Integration**: Full command building with all CLI options
- **MCP Support**: Model Context Protocol servers and tools
- **Error Handling**: Complete exception hierarchy
- **Message Types**: All message and content block types
- **Tool Execution**: Read, Write, Bash tools with proper results
- **Cost Tracking**: Usage and cost information
- **Environment**: Working directory and environment variable support

✅ **Julia-Specific Enhancements:**
- **Type Safety**: Strong typing throughout with union types
- **Performance**: Efficient subprocess handling
- **Error Messages**: Clear, actionable error descriptions
- **Documentation**: Comprehensive inline documentation

## Prerequisites

- Julia 1.10+
- Claude Code CLI installed: `npm install -g @anthropic-ai/claude-code`
- The SDK automatically detects CLI availability and provides helpful error messages

## Testing Strategy

**Comprehensive test suite with 288 tests total** - All ported from Python SDK:

### Test Files Structure:
1. **`test/test_types.jl`** - Message types, options configuration, content blocks
2. **`test/test_errors.jl`** - Error hierarchy, exception handling, string representations  
3. **`test/test_client.jl`** - Query function, message processing, client configuration
4. **`test/test_transport.jl`** - CLI discovery, command building, JSON streaming, process management
5. **`test/test_integration.jl`** - End-to-end testing, CLI integration, comprehensive scenarios

### Test Coverage:
- **Type Construction**: Test SDK component creation and validation
- **Message Types**: Test all message and content block types
- **Tool Functionality**: Test tool creation and execution
- **CLI Integration**: Full end-to-end testing with actual CLI (when available)
- **Error Handling**: Test all exception types and scenarios
- **JSON Streaming**: Test CLI response parsing and message flow
- **Process Management**: Test subprocess lifecycle and error handling

### Test Environment Handling:
Tests gracefully handle CLI availability:
- **Core tests** always run (types, errors, client logic)
- **CLI-dependent tests** only run when `claude` CLI is detected
- **Integration tests** provide both mocked and live CLI scenarios
- Provides clear feedback when CLI is not available
- All 288 tests pass consistently ✅

## Implementation Details

✅ **Complete Implementation:**
- **Environment Setup**: `CLAUDE_CODE_ENTRYPOINT=sdk-jl` for SDK identification
- **CLI Discovery**: Comprehensive search in common installation locations with helpful error messages
- **Command Building**: Dynamic CLI argument construction from all `ClaudeCodeOptions` fields
- **JSON Processing**: Line-by-line streaming JSON response parsing
- **Process Management**: Robust subprocess handling with proper cleanup
- **Error Context**: Detailed error messages with actionable solutions

## API Usage Examples

```julia
using ClaudeCodeSDK

# Basic usage
for message in query(prompt="What is 2 + 2?")
    if message isa AssistantMessage
        for block in message.content
            if block isa TextBlock
                println(block.text)  # Output: 4
            end
        end
    end
end

# Advanced configuration
options = ClaudeCodeOptions(
    system_prompt="You are a helpful Julia assistant",
    allowed_tools=["Read", "Write"],
    permission_mode="acceptEdits",
    max_turns=3,
    model="claude-3-5-sonnet-20241022"
)

for message in query(prompt="Help me with Julia code", options=options)
    # Handle different message types
    if message isa AssistantMessage
        # Process assistant response
    elseif message isa ResultMessage
        println("Cost: \$$(message.cost_usd)")
    end
end
```

## Status: ✅ Complete

The Julia SDK now provides **full feature parity** with the Python SDK:

1. ✅ **API Compatibility**: Exact same function signatures and behavior
2. ✅ **Configuration Options**: All 14 fields supported
3. ✅ **Message Types**: Complete message and content block hierarchy
4. ✅ **Error Handling**: Full exception hierarchy with detailed messages
5. ✅ **CLI Integration**: All CLI options and features supported
6. ✅ **Tool Support**: Read, Write, Bash tools with proper execution
7. ✅ **MCP Support**: Model Context Protocol integration
8. ✅ **Testing**: Comprehensive test coverage (**288 tests passing**)
9. ✅ **Documentation**: Complete API documentation and examples
10. ✅ **Python Test Compatibility**: All Python SDK tests successfully ported to Julia

### Test Suite Highlights:
- **Complete Python Test Port**: All test files from `claude-code-sdk-python/tests/` successfully ported
- **5 Test Files**: `test_types.jl`, `test_errors.jl`, `test_client.jl`, `test_transport.jl`, `test_integration.jl`  
- **288 Total Tests**: Comprehensive coverage matching Python SDK exactly
- **100% Pass Rate**: All tests consistently pass ✅
- **CLI Adaptive**: Tests intelligently handle CLI availability
- **Mock-Friendly**: Julia-adapted mocking for environments without CLI

The implementation successfully bridges Julia's type system with Claude Code's capabilities while maintaining full compatibility with the Python SDK's design patterns and functionality. The comprehensive test suite ensures reliability and feature parity.

