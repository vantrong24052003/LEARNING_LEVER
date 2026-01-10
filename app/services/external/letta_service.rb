# frozen_string_literal: true

module External
  class LettaService
    STOP_REASON_REQUIRES_APPROVAL = "requires_approval"
    HTTP_CONFLICT_CODE = "409"
    ERROR_PENDING_APPROVAL = "PENDING_APPROVAL"

    def initialize
      @client = External::Letta::Client.new
    end

    def execute(params)
      return { error: "Missing params", status: :bad_request } if params[:message].blank? || params[:agent_id].blank?

      response = @client.send_message(agent_id: params[:agent_id], content: params[:message])
      handle_chat_response(response, params)
    rescue External::Letta::Client::Error => e
      handle_client_error(e, params)
    end

    def execute_tools(params)
      tool_calls = External::Letta::MessageParser.new(params).extract_execution_tool_calls
      execute_and_send_outputs(tool_calls, params[:agent_id], params)
    end

    private

    def handle_chat_response(response, params)
      parser = External::Letta::MessageParser.new(response)

      if parser.extract_stop_reason == STOP_REASON_REQUIRES_APPROVAL
        handle_approval_from_response(parser, params)
      elsif (tool_calls = parser.extract_tool_calls).any?
        handle_auto_tool_execution(tool_calls, params)
      else
        { response: }
      end
    end

    def handle_approval_from_response(parser, params)
      approval_message = parser.extract_approval_message
      tool_calls = parser.extract_approval_tool_call(approval_message)

      @client.send_approval(agent_id: params[:agent_id], approval_request_id: approval_message["id"])
      execute_and_send_outputs(tool_calls, params[:agent_id])
    end

    def handle_auto_tool_execution(tool_calls, params)
      execute_and_send_outputs(tool_calls, params[:agent_id], params)
    end

    def execute_and_send_outputs(tool_calls, agent_id, params = {})
      tool_outputs = External::Letta::Executor.new.call(tool_calls)
      response = @client.send_tool_outputs(agent_id:, tool_outputs:)
      handle_chat_response(response, params.merge(agent_id:))
    end

    def handle_client_error(error, params)
      if pending_approval_error?(error)
        approval_id = External::Letta::MessageParser.extract_approval_id(error.message)
        final_response = @client.send_approval(agent_id: params[:agent_id], approval_request_id: approval_id)
        { response: final_response }
      else
        raise error
      end
    end

    def pending_approval_error?(error)
      error.message.include?(HTTP_CONFLICT_CODE) && error.message.include?(ERROR_PENDING_APPROVAL)
    end
  end
end
