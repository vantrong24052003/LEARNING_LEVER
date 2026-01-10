
require_relative "../config/environment"

agent_id = "agent-5123a916-c054-4723-aaa6-9cca47a78bdd"
client = External::Client.new

puts "Fetching messages for agent: #{agent_id}"

begin
  response = client.list_messages(agent_id: agent_id)
  puts "Response class: #{response.class}"
  puts "Response keys: #{response.keys}" if response.is_a?(Hash)
  
  # Simulate Controller Logic
  msg_response = response
  raw_msgs = msg_response.dig("data", "messages") || msg_response["messages"]
  puts "Raw Msgs class: #{raw_msgs.class}"
  
  if raw_msgs.is_a?(Hash)
    puts "Raw Msgs keys: #{raw_msgs.keys}"
    messages = raw_msgs["body"] if raw_msgs["body"]
  else
    messages = raw_msgs
  end
  messages ||= []
  
  puts "Parsed Messages count: #{messages.size}"
  puts "Last 3 messages types: #{messages.last(3).map{|m| m['message_type']}}"

  pending_msg = messages.reverse.find { |m| m["message_type"] == "tool_call_message" || m["message_type"] == "approval_request_message" }
  puts "Pending Msg found: #{!pending_msg.nil?}"
  if pending_msg
    puts "Pending Msg Type: #{pending_msg['message_type']}"
    puts "Tool Call: #{pending_msg['tool_call'] || pending_msg['tool_calls']}"
  end
  
rescue => e
  puts "Error: #{e.message}"
end
