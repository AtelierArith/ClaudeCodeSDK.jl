"""
Internal client implementation
"""
struct InternalClient
    InternalClient() = new()
end

"""
Process a query through transport
"""
function process_query(client::InternalClient, prompt::String, options::ClaudeCodeOptions)
    transport = SubprocessCLITransport(prompt, options)
    
    messages = Message[]
    
    try
        connect!(transport)
        
        for data in receive_messages(transport)
            message = parse_message(data)
            if message !== nothing
                push!(messages, message)
            end
        end
        
    finally
        disconnect!(transport)
    end
    
    return messages
end