using ClaudeCodeSDK

println("Tool Execution Demo")
println("=" ^ 30)

# Create a test file for reading
test_file = "demo_test.txt"
test_content = "Hello from Julia ClaudeCodeSDK!\nThis is a test file.\nLine 3 content."

println("\n1. Testing WriteTool execution:")
write_tool = WriteTool(test_file, test_content)
write_result = execute_tool(write_tool)
println("   Write success: $(write_result.success)")
println("   Write output: $(write_result.output)")
if write_result.success
    println("   ✓ File created successfully")
end

println("\n2. Testing ReadTool execution:")
read_tool = ReadTool(test_file)
read_result = execute_tool(read_tool)
println("   Read success: $(read_result.success)")
if read_result.success
    println("   ✓ File read successfully")
    println("   Content preview: $(first(read_result.output, 50))...")
else
    println("   ✗ Read failed: $(read_result.error)")
end

println("\n3. Testing BashTool execution:")
bash_tool = BashTool("echo 'Hello from Julia Bash execution!'")
bash_result = execute_tool(bash_tool)
println("   Bash success: $(bash_result.success)")
if bash_result.success
    println("   ✓ Bash command executed")
    println("   Output: $(strip(bash_result.output))")
else
    println("   ✗ Bash failed: $(bash_result.error)")
end

println("\n4. Testing tool creation from ToolUseBlock:")
# Simulate what would come from Claude Code CLI
tool_block = ToolUseBlock("tool_456", "Write", Dict(
    "file_path" => "created_from_block.txt",
    "content" => "This file was created from a ToolUseBlock!"
))

created_tool = create_tool_from_block(tool_block)
if created_tool isa WriteTool
    println("   ✓ Successfully created WriteTool from block")
    result = execute_tool(created_tool)
    if result.success
        println("   ✓ Tool executed successfully: $(result.output)")
    end
end

# Cleanup
println("\n5. Cleanup:")
try
    rm(test_file)
    println("   ✓ Removed $(test_file)")
catch
    println("   - $(test_file) already removed")
end

try
    rm("created_from_block.txt")
    println("   ✓ Removed created_from_block.txt")
catch
    println("   - created_from_block.txt already removed")
end

println("\n" * "=" ^ 30)
println("✓ Tool execution demo completed!")
