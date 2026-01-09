module External
  class Client
    class Error < StandardError; end

    DEFAULT_BASE_URL = "http://localhost:4000/api/"
    TOOLS_PATH = "agents/tools"
    MESSAGES_PATH = "agents/%{agent_id}/messages"
    ROLE_USER = "user"
    ROLE_TOOL = "tool"

    def initialize(base_url: DEFAULT_BASE_URL, api_key: nil)
      @base_url = base_url
      @api_key = api_key
    end

    def send_message(agent_id:, content:, role: ROLE_USER)
      path = format(MESSAGES_PATH, agent_id: agent_id)
      body = { message: content, role: role }
      
      handle_response(connection.post(path) { |req| req.body = body.to_json })
    end

    def send_tool_outputs(agent_id:, tool_outputs:)
      path = format(MESSAGES_PATH, agent_id: agent_id)
      messages = tool_outputs.map { |o| { role: ROLE_TOOL, content: o[:output], tool_call_id: o[:tool_call_id] } }
      
      handle_response(connection.post(path) { |req| req.body = { messages: messages }.to_json })
    end

    def list_messages(agent_id:)
      path = format(MESSAGES_PATH, agent_id: agent_id)
      handle_response(connection.get(path))
    end

    def register_tool(tool_definition)
      handle_response(connection.post(TOOLS_PATH) { |req| req.body = tool_definition.to_json })
    end

    private

    def connection
      @connection ||= Faraday.new(url: @base_url) do |conn|
        conn.options.open_timeout = 120
        conn.options.timeout = 120
        conn.request :json
        conn.response :json
        conn.headers["Authorization"] = "Bearer #{@api_key}" if @api_key.present?
        conn.adapter Faraday.default_adapter
      end
    end

    def handle_response(response)
      return response.body if response.success?
      raise Error, "Letta API Error: #{response.status} - #{response.body}"
    end
  end
end
