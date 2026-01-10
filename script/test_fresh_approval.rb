require_relative "../config/environment"

agent_id = "agent-3f4b37b5-a448-4408-a836-b96cbbab5115"
client = External::Client.new

puts "=" * 80
puts "Testing HITL Approval Flow with Fresh Agent"
puts "Agent ID: #{agent_id}"
puts "=" * 80

puts "\nSTEP 1: Fetching current messages"
msg_response = client.list_messages(agent_id: agent_id)
raw_msgs = msg_response.dig("data", "messages") || msg_response["messages"]
messages = raw_msgs.is_a?(Hash) && raw_msgs["body"] ? raw_msgs["body"] : raw_msgs
messages ||= []

puts "✓ Total messages: #{messages.size}"
puts "✓ Last 3 message types: #{messages.last(3).map { |m| m['message_type'] }}"

pending_msg = messages.reverse.find { |m| m["message_type"] == "approval_request_message" }

if pending_msg
  puts "\nSTEP 2: Found Approval Request ✓"
  puts "  - ID: #{pending_msg['id']}"
  puts "  - Tool: #{pending_msg['tool_call']['name'] rescue 'N/A'}"
  
  puts "\nSTEP 3: Sending Approval..."
  begin
    approval_resp = client.send_approval(
      agent_id: agent_id,
      approval_request_id: pending_msg["id"],
      approve: true
    )
    puts "✓ Approval sent successfully"
    puts "  Response keys: #{approval_resp.keys.inspect}" if approval_resp.is_a?(Hash)
  rescue => e
    puts "✗ ERROR: #{e.message}"
    exit 1
  end
  
  puts "\nSTEP 4: Waiting 3 seconds for agent processing..."
  sleep 3
  
  puts "\nSTEP 5: Fetching messages again..."
  msg_response2 = client.list_messages(agent_id: agent_id)
  raw_msgs2 = msg_response2.dig("data", "messages") || msg_response2["messages"]
  messages2 = raw_msgs2.is_a?(Hash) && raw_msgs2["body"] ? raw_msgs2["body"] : raw_msgs2
  messages2 ||= []
  
  puts "✓ Total messages now: #{messages2.size}"
  puts "  New messages added: #{messages2.size - messages.size}"
  
  puts "\n  Last 5 message types:"
  messages2.last(5).each_with_index do |m, i|
    puts "    #{i+1}. #{m['message_type']}"
  end
  
  tool_call_msg = messages2.reverse.find { |m| m["message_type"] == "tool_call_message" }
  if tool_call_msg
    puts "\n✅ SUCCESS: Found tool_call_message!"
    puts "  Tool Call ID: #{tool_call_msg['id']}"
    puts "  Tool Calls: #{tool_call_msg['tool_calls'] || tool_call_msg['tool_call']}"
    
    puts "\n  Now we can execute the tool and send output..."
  else
    puts "\n❌ NO tool_call_message found"
    puts "  This means the agent didn't generate a tool call after approval"
  end
else
  puts "\n❌ No approval_request_message found in messages"
  puts "  Agent state might be clean or already processed"
end
