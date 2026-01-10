require_relative "../config/environment"
require "json"

agent_id = "agent-3f4b37b5-a448-4408-a836-b96cbbab5115"

log_data = File.read("postman/3_chat.log")
json_start = log_data.index("{")
json_data = log_data[json_start..-1]

response = JSON.parse(json_data)

puts "=" * 80
puts "RESPONSE ANALYSIS"
puts "=" * 80

messages = response.dig("data", "data", "response", "messages")
stop_reason = response.dig("data", "data", "response", "stop_reason", "stop_reason")

puts "Stop Reason: #{stop_reason}"
puts "Messages Count: #{messages&.size || 0}"

if messages
  messages.each_with_index do |msg, i|
    puts "\nMessage #{i+1}:"
    puts "  Type: #{msg['message_type']}"
    puts "  ID: #{msg['id']}"
    if msg['tool_call']
      puts "  Tool: #{msg['tool_call']['name']}"
      puts "  Tool Call ID: #{msg['tool_call']['tool_call_id']}"
    end
  end
end

puts "\n" + "=" * 80
puts "CONCLUSION"
puts "=" * 80

if stop_reason == "requires_approval"
  approval_msg = messages&.find { |m| m['message_type'] == 'approval_request_message' }
  if approval_msg
    puts "✓ This is a SUCCESS response (200) with approval request"
    puts "✓ Message ID: #{approval_msg['id']}"
    puts "✓ Need to send approval for this ID"
    puts "\n⚠️  Our code expects 409 error, but Letta returns 200!"
  end
else
  puts "❌ Unexpected stop reason: #{stop_reason}"
end
