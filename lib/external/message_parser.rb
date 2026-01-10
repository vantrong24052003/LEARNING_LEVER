module External
  class MessageParser
    def self.extract_messages(response)
      raw = response.dig("data", "messages") || response["messages"] || []
      raw.is_a?(Hash) && raw["body"] ? raw["body"] : Array(raw)
    end
    
    def self.extract_approval_id(error_message)
      error_message[/pending_request_id['":\s]+['"]([^'"]+)['"]/, 1]
    end
  end
end
