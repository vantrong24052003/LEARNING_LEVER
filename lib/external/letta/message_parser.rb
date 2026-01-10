# frozen_string_literal: true

module External
  module Letta
    class MessageParser
      APPROVAL_REQUEST_MESSAGE = "approval_request_message"
      TOOL_CALL_MESSAGE = "tool_call_message"

      def initialize(data)
        @data = data || {}
      end

      def extract_messages
        @data.dig("data", "response", "messages") || []
      end

      def extract_stop_reason
        @data.dig("data", "response", "stop_reason", "stop_reason")
      end

      def extract_tool_calls
        tool_message = extract_messages.find { |message| message["message_type"] == TOOL_CALL_MESSAGE }
        return [] if tool_message.nil? || tool_message["tool_calls"].nil?

        tool_message["tool_calls"].filter_map { |tool_call| format_tool_call(tool_call) }
      end

      def extract_execution_tool_calls
        raw_tool_calls = @data["tool_calls"] || []
        raw_tool_calls.filter_map { |tool_call| format_tool_call(tool_call) }
      end

      def extract_approval_message
        extract_messages.find { |message| message["message_type"] == APPROVAL_REQUEST_MESSAGE }
      end

      def extract_approval_tool_call(message)
        tool_call_data = message&.dig("tool_call")
        return [] if tool_call_data.nil?

        [{ id: tool_call_data["tool_call_id"], name: tool_call_data["name"],
arguments: parse_arguments(tool_call_data["arguments"]), }]
      end

      def self.extract_approval_id(error_message)
        error_message.to_s.match(/pending_request_id['":\s]+['"]([^'"]+)['"]/)&.[](1)
      end

      private

      def format_tool_call(tool_call)
        return nil if !tool_call.is_a?(Hash) || tool_call["function"].nil?

        { id: tool_call["id"], name: tool_call.dig("function", "name"),
arguments: parse_arguments(tool_call.dig("function", "arguments")), }
      end

      def parse_arguments(arguments)
        return arguments unless arguments.is_a?(String)

        JSON.parse(arguments)
      rescue JSON::ParserError, TypeError
        {}
      end
    end
  end
end
