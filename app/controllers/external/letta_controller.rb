module External
  class LettaController < ApplicationController
    skip_forgery_protection only: :create

    def create
      Rails.logger.info "DEBUG: INCOMING REQUEST"
      Rails.logger.info "DEBUG: Params: #{params.to_unsafe_h.inspect}"

      if params[:tool_calls].present? || params[:function].present? || params[:tool_call].present?
       execute_tools_and_respond
        return
      end

      return render_error(error: "Message and Agent ID are required", status: :bad_request) if params[:message].blank? || params[:agent_id].blank?

      client = External::Client.new
      response = client.send_message(agent_id: params[:agent_id], content: params[:message])
      
      if requires_approval?(response)
        handle_approval_from_response(response, client)
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
      Rails.logger.error "Letta Controller Error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render_error(error: e.message)
    end

    private

    def requires_approval?(response)
      messages = response.dig("data", "response", "messages") || response["messages"] || []
      stop_reason = response.dig("data", "response", "stop_reason", "stop_reason") || response.dig("stop_reason", "stop_reason")
      
      stop_reason == "requires_approval" && messages.any? { |m| m["message_type"] == "approval_request_message" }
    end

    def pending_approval_error?(error)
      error.message.include?("409") && error.message.include?("PENDING_APPROVAL")
    end

    def handle_approval_from_response(response, client)
      messages = response.dig("data", "response", "messages") || response["messages"] || []
      approval_msg = messages.find { |m| m["message_type"] == "approval_request_message" }
      
      unless approval_msg
        Rails.logger.error "No approval_request_message found in response"
        return render_error(error: "Approval request not found")
      end
      
      approval_id = approval_msg["id"]
      tool_call_data = approval_msg["tool_call"] || (approval_msg["tool_calls"] && approval_msg["tool_calls"].first)
      
      unless tool_call_data
        Rails.logger.error "No tool_call data in approval message"
        return render_error(error: "Tool call data not found")
      end
      
      Rails.logger.info "DEBUG: Auto-approving: #{approval_id}"
      
      client.send_approval(
        agent_id: params[:agent_id],
        approval_request_id: approval_id
      )
      
      Rails.logger.info "DEBUG: Executing tool: #{tool_call_data['name']}"
      
      normalized_call = {
        id: tool_call_data["tool_call_id"] || tool_call_data["id"],
        name: tool_call_data["name"],
        arguments: tool_call_data["arguments"]
      }
      
      tool_outputs = External::Executor.new.call([normalized_call])
      
      Rails.logger.info "DEBUG: Sending tool outputs to Letta"
      
      final_response = client.send_tool_outputs(
        agent_id: params[:agent_id],
        tool_outputs: tool_outputs
      )
      
      render_success(response: final_response)
    end

    def handle_approval_from_error(error, client)
      approval_id = External::MessageParser.extract_approval_id(error.message)
      
      unless approval_id
        Rails.logger.error "Failed to extract approval ID from error: #{error.message}"
        raise error
      end
      
      Rails.logger.info "DEBUG: Auto-approving from error: #{approval_id}"
      
      approval_response = client.send_approval(
        agent_id: params[:agent_id],
        approval_request_id: approval_id
      )
      
      render_success(response: approval_response)
    end

    def execute_tools_and_respond
      Rails.logger.info "DEBUG: Executing tools from Letta"
      
      raw_calls = params[:tool_calls] || [params[:tool_call] || params[:function]].compact
      tool_calls = raw_calls.map do |tc|
        {
          id: tc["tool_call_id"] || tc["id"],
          name: tc["name"] || (tc["function"] && tc["function"]["name"]),
          arguments: tc["arguments"] || (tc["function"] && tc["function"]["arguments"])
        }
      end
      
      tool_outputs = External::Executor.new.call(tool_calls)
      render_success(response: { tool_outputs: tool_outputs })
    end
  end
end
