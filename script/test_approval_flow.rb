require_relative "../config/environment"

agent_id = "agent-5123a916-c054-4723-aaa6-9cca47a78bdd"
client = External::Client.new

puts "=" * 80
puts "STEP 1: Fetching current messages"
puts "=" * 80

msg_response = client.list_messages(agent_id: agent_id)
raw_msgs = msg_response.dig("data", "messages") || msg_response["messages"]
messages = raw_msgs.is_a?(Hash) && raw_msgs["body"] ? raw_msgs["body"] : raw_msgs
messages ||= []

puts "Total messages: #{messages.size}"
puts "Last 3 message types: #{messages.last(3).map { |m| m['message_type'] }}"

pending_msg = messages.reverse.find { |m| m["message_type"] == "approval_request_message" }

if pending_msg
  puts "\n" + "=" * 80
  puts "STEP 2: Found Approval Request"
  puts "=" * 80
  puts "Approval Request ID: #{pending_msg['id']}"
  puts "Tool Call: #{pending_msg['tool_call']}"
  
  puts "\n" + "=" * 80
  puts "STEP 3: Sending Approval"
  puts "=" * 80
  
  begin
    approval_response = client.send_approval(
      agent_id: agent_id,
      approval_request_id: pending_msg["id"]
    )
    puts "Approval sent successfully!"
    puts "Response: #{approval_response.inspect}"
  rescue => e
    puts "ERROR sending approval: #{e.message}"
    exit 1
  end
  
  puts "\n" + "=" * 80
  puts "STEP 4: Waiting for agent to process..."
  puts "=" * 80
  sleep 3
  
  puts "\n" + "=" * 80
  puts "STEP 5: Fetching messages again"
  puts "=" * 80
  
  msg_response2 = client.list_messages(agent_id: agent_id)
  raw_msgs2 = msg_response2.dig("data", "messages") || msg_response2["messages"]
  messages2 = raw_msgs2.is_a?(Hash) && raw_msgs2["body"] ? raw_msgs2["body"] : raw_msgs2
  messages2 ||= []
  
  puts "Total messages now: #{messages2.size}"
  puts "Last 5 message types: #{messages2.last(5).map { |m| m['message_type'] }}"
  
  tool_call_msg = messages2.reverse.find { |m| m["message_type"] == "tool_call_message" }
  if tool_call_msg
    puts "\n✅ SUCCESS: Found tool_call_message!"
    puts "Tool Call: #{tool_call_msg['tool_calls'] || tool_call_msg['tool_call']}"
  else
    puts "\n❌ FAILURE: No tool_call_message found after approval"
  end
else
  puts "❌ No pending approval request found"
end
