# Error Handling

ClaudeCodeSDK.jl provides a comprehensive error handling system to help you deal with various failure scenarios when interacting with the Claude CLI.

## Exception Hierarchy

All SDK-specific exceptions inherit from the base `ClaudeSDKError` type:

```julia
abstract type ClaudeSDKError <: Exception end
```

### Core Exception Types

#### CLINotFoundError

Thrown when the Claude CLI is not installed or not found in the system PATH.

```julia
struct CLINotFoundError <: ClaudeSDKError
    message::String
end
```

**Common causes:**
- Claude CLI not installed (`npm install -g @anthropic-ai/claude-code`)
- CLI not in system PATH
- Incorrect CLI command name

**Example:**
```julia
try
    result = query("Hello")
catch e
    if e isa CLINotFoundError
        println("Please install Claude CLI: npm install -g @anthropic-ai/claude-code")
    end
end
```

#### CLIConnectionError

Thrown when there are connection issues with the Claude CLI.

```julia
struct CLIConnectionError <: ClaudeSDKError
    message::String
end
```

**Common causes:**
- Network connectivity issues
- Claude API authentication problems
- Service unavailability

#### ProcessError

Thrown when the CLI process fails or returns a non-zero exit code.

```julia
struct ProcessError <: ClaudeSDKError
    exit_code::Int
    output::String
end
```

**Common causes:**
- Invalid CLI arguments
- Authentication failures
- Resource limitations
- CLI internal errors

**Example:**
```julia
try
    result = query("Hello")
catch e
    if e isa ProcessError
        println("CLI failed with exit code: $(e.exit_code)")
        println("Error output: $(e.output)")
    end
end
```

#### CLIJSONDecodeError

Thrown when the SDK cannot parse the CLI's JSON response.

```julia
struct CLIJSONDecodeError <: ClaudeSDKError
    message::String
    raw_output::String
end
```

**Common causes:**
- Malformed JSON output from CLI
- Unexpected response format
- CLI version incompatibility
- Partial or truncated responses

## Error Handling Patterns

### Basic Error Handling

```julia
using ClaudeCodeSDK

try
    result = query("What is 2 + 2?")
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
    println("Error occurred: $e")
end
```

### Comprehensive Error Handling

```julia
using ClaudeCodeSDK

function safe_query(prompt::String, options=nothing)
    try
        return query(prompt, options=options)
    catch e
        if e isa CLINotFoundError
            @error "Claude CLI not found" exception=e
            println("Solution: Install Claude CLI with 'npm install -g @anthropic-ai/claude-code'")
            return Message[]
        elseif e isa CLIConnectionError
            @error "Connection to Claude failed" exception=e
            println("Check your internet connection and Claude API credentials")
            return Message[]
        elseif e isa ProcessError
            @error "CLI process failed" exit_code=e.exit_code output=e.output
            if e.exit_code == 1
                println("Authentication or permission error")
            elseif e.exit_code == 2
                println("Invalid arguments or configuration")
            else
                println("Unexpected CLI error")
            end
            return Message[]
        elseif e isa CLIJSONDecodeError
            @error "Failed to parse CLI response" raw_output=e.raw_output exception=e
            println("This might indicate a CLI version incompatibility")
            return Message[]
        else
            @error "Unexpected error" exception=e
            rethrow(e)  # Re-throw unknown errors
        end
    end
end

# Usage
result = safe_query("Hello Claude")
if !isempty(result)
    println("Query successful!")
else
    println("Query failed, check error messages above")
end
```

### Retry Logic

```julia
using ClaudeCodeSDK

function query_with_retry(prompt::String; max_retries=3, delay=1.0, options=nothing)
    for attempt in 1:max_retries
        try
            return query(prompt, options=options)
        catch e
            if e isa CLIConnectionError && attempt < max_retries
                @warn "Connection failed, retrying in $(delay) seconds..." attempt=attempt
                sleep(delay)
                delay *= 2  # Exponential backoff
                continue
            else
                rethrow(e)
            end
        end
    end
end

# Usage
try
    result = query_with_retry("Hello Claude", max_retries=3)
    println("Success after retry!")
catch e
    println("Failed after all retries: $e")
end
```

### Logging and Debugging

```julia
using ClaudeCodeSDK
using Logging

# Enable debug logging
with_logger(ConsoleLogger(stderr, Logging.Debug)) do
    try
        result = query("Debug test")
        @debug "Query successful" result_length=length(result)
    catch e
        @error "Query failed" exception=(e, catch_backtrace())
        
        # Additional debugging information
        if e isa ProcessError
            @debug "Process details" exit_code=e.exit_code output=e.output
        elseif e isa CLIJSONDecodeError
            @debug "JSON parsing details" raw_output=e.raw_output
        end
    end
end
```

## Testing Error Conditions

### Mocking Errors for Testing

```julia
using ClaudeCodeSDK
using Test

# Test error handling without actual CLI
@testset "Error Handling Tests" begin
    @testset "CLINotFoundError" begin
        error = CLINotFoundError("CLI not found")
        @test error isa CLINotFoundError
        @test error isa ClaudeSDKError
        @test error.message == "CLI not found"
    end
    
    @testset "ProcessError" begin
        error = ProcessError(1, "Authentication failed")
        @test error isa ProcessError
        @test error.exit_code == 1
        @test error.output == "Authentication failed"
    end
    
    @testset "CLIJSONDecodeError" begin
        error = CLIJSONDecodeError("Invalid JSON", "{invalid")
        @test error isa CLIJSONDecodeError
        @test error.message == "Invalid JSON"
        @test error.raw_output == "{invalid"
    end
end
```

### CLI Availability Testing

```julia
using ClaudeCodeSDK

function test_cli_availability()
    try
        # Try a simple query to test CLI
        result = query("test")
        return true, "CLI is working"
    catch e
        if e isa CLINotFoundError
            return false, "CLI not installed"
        elseif e isa CLIConnectionError
            return false, "CLI connection failed"
        elseif e isa ProcessError
            return false, "CLI process error: $(e.exit_code)"
        else
            return false, "Unknown error: $e"
        end
    end
end

# Usage in tests
is_available, message = test_cli_availability()
if is_available
    println("✓ CLI tests can run")
else
    println("⚠ CLI tests will be skipped: $message")
end
```

## Best Practices

### 1. Always Use Try-Catch

Never call `query()` without error handling in production code:

```julia
# Bad
result = query("Hello")  # Can throw exceptions

# Good
try
    result = query("Hello")
    # Handle result
catch e
    # Handle error
end
```

### 2. Provide User-Friendly Error Messages

```julia
try
    result = query(prompt)
catch e
    if e isa CLINotFoundError
        println("❌ Claude CLI is not installed.")
        println("📦 Install it with: npm install -g @anthropic-ai/claude-code")
    elseif e isa ProcessError
        println("❌ Query failed. Check your Claude configuration.")
    else
        println("❌ An unexpected error occurred: $e")
    end
end
```

### 3. Log Errors for Debugging

```julia
using Logging

try
    result = query(prompt)
catch e
    @error "Query failed" prompt=prompt exception=e
    # Handle error gracefully
end
```

### 4. Implement Graceful Degradation

```julia
function get_claude_response(prompt::String; fallback="Sorry, I couldn't process your request.")
    try
        result = query(prompt)
        # Extract text from result
        for message in result
            if message isa AssistantMessage
                for block in message.content
                    if block isa TextBlock
                        return block.text
                    end
                end
            end
        end
        return fallback
    catch e
        @warn "Claude query failed, using fallback" exception=e
        return fallback
    end
end
```

### 5. Test Error Scenarios

Always test your error handling code:

```julia
@testset "Error Scenarios" begin
    # Test with invalid options
    invalid_options = ClaudeCodeOptions(max_turns=-1)  # Invalid
    @test_throws ProcessError query("test", options=invalid_options)
    
    # Test graceful degradation
    response = get_claude_response("test", fallback="fallback")
    @test response isa String
end
```

## Debugging Tips

### Enable Verbose Output

```julia
# If CLI supports verbose mode
options = ClaudeCodeOptions(suppress_client_logs=false)
result = query("Debug query", options=options)
```

### Capture Raw CLI Output

```julia
# For debugging CLI communication issues
try
    result = query("test")
catch e
    if e isa CLIJSONDecodeError
        println("Raw CLI output:")
        println(e.raw_output)
    end
end
```

### Check CLI Version Compatibility

```julia
function check_cli_version()
    try
        # This would need to be implemented based on CLI capabilities
        output = read(`claude --version`, String)
        println("Claude CLI version: $output")
    catch e
        println("Could not determine CLI version: $e")
    end
end
```

The error handling system in ClaudeCodeSDK.jl is designed to provide clear, actionable feedback while maintaining robust operation even when the underlying CLI encounters issues.