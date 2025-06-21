using Markdown
using ClaudeCodeSDK

options = ClaudeCodeOptions(
    allowed_tools=["Read", "Write", "Bash"],
    max_thinking_tokens=8000,
    system_prompt="You are a helpful assistant",
    append_system_prompt=nothing,
    mcp_tools=String[],
    mcp_servers=Dict{String, McpServerConfig}(),
    permission_mode="acceptEdits",
    continue_conversation=false,
    resume=nothing,
    max_turns=20,
    disallowed_tools=String[],
    model="claude-sonnet-4-20250514",
    permission_prompt_tool_name=nothing,
    cwd="."
)

result = query_stream(
	prompt="Create a Julia package named Example.jl package that exports hello function", 
	options=options
)

for m in result
	if m isa AssistantMessage
		for c in m.content
			if c isa TextBlock
				display(Markdown.parse(c.text))
			end
		end
	end
end