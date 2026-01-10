module External
  class MessageParser
   ApprovalRequestMessage = "approval_request_message"

    def self.extract_messages(response)
      response["data"]["data"]["response"]["messages"]
    end

    def self.extract_stop_reason(response)
      response["data"]["data"]["response"]["stop_reason"]["stop_reason"]
    end

    def self.extract_tool_calls(response)
      messages = extract_messages(response)
      tool_msg = messages.find { |m| m["message_type"] == "tool_call_message" }
      return [] unless tool_msg
      
      tool_msg["tool_calls"].map do |tc|
        {
          id: tc["id"],
          name: tc["function"]["name"],
          arguments: JSON.parse(tc["function"]["arguments"])
        }
      end
    end

    def self.extract_approval_msg(response)
      messages = extract_messages(response)
      messages.find { |m| m["message_type"] == ApprovalRequestMessage }
    end

    def self.extract_approval_tool_call(msg)
      tc = msg["tool_call"]
      [{
        id: tc["tool_call_id"],
        name: tc["name"],
        arguments: JSON.parse(tc["arguments"])
      }]
    end

    def self.extract_execution_tool_calls(params)
      params["tool_calls"].map do |tc|
        {
          id: tc["id"],
          name: tc["function"]["name"],
          arguments: JSON.parse(tc["function"]["arguments"])
        }
      end
    end

    def self.extract_approval_id(error_message)
      error_message.match(/pending_request_id['":\s]+['"]([^'"]+)['"]/)[1]
    end
  end
end
