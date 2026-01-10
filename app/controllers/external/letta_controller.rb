module External
  class LettaController < ApplicationController
    skip_forgery_protection only: :create

    def create
      if is_tool_execution_request?
        execute_tools_and_respond
        return
      end

      if params[:message].blank? || params[:agent_id].blank?
        render_error(error: "Missing params", status: :bad_request)
        return
      end

      client = External::Client.new
      response = client.send_message(agent_id: params[:agent_id], content: params[:message])
      
      if requires_approval?(response)
        handle_approval_from_response(response, client)
      elsif (tool_calls = External::MessageParser.extract_tool_calls(response)).any?
        handle_auto_tool_execution(tool_calls, client)
      else
        render_success(response: response)
      end
    rescue External::Client::Error => e
      if pending_approval_error?(e)
        handle_approval_from_error(e, client)
      else
        raise e
      end
    rescue StandardError => e
      render_error(error: e.message)
    end

    private

    def is_tool_execution_request?
      params.key?(:tool_calls)
    end

    def requires_approval?(response)
      External::MessageParser.extract_stop_reason(response) == "requires_approval"
    end

    def pending_approval_error?(error)
      error.message.include?("409") && error.message.include?("PENDING_APPROVAL")
    end

    def handle_approval_from_response(response, client)
      approval_msg = External::MessageParser.extract_approval_msg(response)
      approval_id = approval_msg["id"]
      tool_calls = External::MessageParser.extract_approval_tool_call(approval_msg)
      
      client.send_approval(agent_id: params[:agent_id], approval_request_id: approval_id)
      
      tool_outputs = External::Executor.new.call(tool_calls)
      final_response = client.send_tool_outputs(agent_id: params[:agent_id], tool_outputs: tool_outputs)
      
      render_success(response: final_response)
    end

    def handle_approval_from_error(error, client)
      approval_id = External::MessageParser.extract_approval_id(error.message)
      approval_response = client.send_approval(agent_id: params[:agent_id], approval_request_id: approval_id)
      render_success(response: approval_response)
    end

    def handle_auto_tool_execution(tool_calls, client)
      tool_outputs = External::Executor.new.call(tool_calls)
      final_response = client.send_tool_outputs(agent_id: params[:agent_id], tool_outputs: tool_outputs)
      render_success(response: final_response)
    end

    def execute_tools_and_respond
      tool_calls = External::MessageParser.extract_execution_tool_calls(params)
      tool_outputs = External::Executor.new.call(tool_calls)
      render_success(response: { tool_outputs: tool_outputs })
    end
  end
end
