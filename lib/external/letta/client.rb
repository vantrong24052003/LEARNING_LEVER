# frozen_string_literal: true

module External
  module Letta
    class Client < Base
      class Error < StandardError; end

      DEFAULT_BASE_URL = "http://localhost:4000/api/letta/"
      ROLES = { user: "user", system: "system", approval: "approval" }.freeze

      def initialize(base_url: DEFAULT_BASE_URL, api_key: nil)
        super
      end

      def send_message(agent_id:, content:, role: ROLES[:user])
        post_request(messages_path(agent_id), { message: content, role: })
      end

      def send_approval(agent_id:, approval_request_id:, approve: true)
        post_request(messages_path(agent_id),
                     { type: ROLES[:approval], approve:, approval_request_id:, role: ROLES[:user] })
      end

      def send_tool_outputs(agent_id:, tool_outputs:)
        formatted_messages = tool_outputs.map do |data|
          { role: ROLES[:system], content: "Tool '#{data[:name]}' output: #{data[:output]}" }
        end
        post_request(messages_path(agent_id), { messages: formatted_messages })
      end

      def list_messages(agent_id:)
        get_request(messages_path(agent_id))
      end

      def register_tool(tool_definition)
        post_request(Endpoints::PATHS[:tools], tool_definition)
      end

      private

      def messages_path(agent_id)
        format(Endpoints::PATHS[:messages], agent_id)
      end
    end
  end
end
