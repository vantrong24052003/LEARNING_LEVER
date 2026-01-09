module External
  class LettaController < ApplicationController
    skip_forgery_protection only: :create

    def create
      Rails.logger.info "DEBUG: INCOMING REQUEST TO LETTA CONTROLLER!"
      Rails.logger.info "DEBUG: Params: #{params.to_unsafe_h.inspect}"

      # Check if this is an incoming tool execution request from Letta (Project 1)
      if params[:tool_calls].present? || params[:function].present? || params[:tool_call].present?
        Rails.logger.info "DEBUG: Detected incoming TOOL CALL from Project 1. Executing..."
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
        return
      end

      # Otherwise, it's a message from User to forward to Letta (the Brain)
      return render_error(error: "Message and Agent ID are required", status: :bad_request) if params[:message].blank? || params[:agent_id].blank?

      client = External::Client.new
      response_hash = client.send_message(agent_id: params[:agent_id], content: params[:message])
      incoming_msgs = response_hash["messages"] || []

      tool_calls_from_msgs = incoming_msgs.select { |m| m["message_type"] == "tool_call_message" || (m["tool_calls"] && m["tool_calls"].any?) }
                                  .flat_map { |m| m["tool_calls"] || [] }
      
      tool_calls_from_approvals = incoming_msgs.select { |m| m["message_type"] == "approval_request_message" && m["tool_call"] }
                                          .map { |m| m["tool_call"] }

      # Normalize Letta format to a consistent internal structure
      tool_calls = (tool_calls_from_msgs + tool_calls_from_approvals).map do |tc|
        {
          id: tc["tool_call_id"] || tc["id"],
          name: tc["name"] || (tc["function"] && tc["function"]["name"]),
          arguments: tc["arguments"] || (tc["function"] && tc["function"]["arguments"])
        }
      end

      if tool_calls.any?
        Rails.logger.info "DEBUG: Found #{tool_calls.size} tool calls. Executing..."
        tool_outputs = External::Executor.new.call(tool_calls)
        Rails.logger.info "DEBUG: Tool execution finished. Sending outputs back to Letta..."
        render_success(response: client.send_tool_outputs(agent_id: params[:agent_id], tool_outputs: tool_outputs))
      else
        Rails.logger.info "DEBUG: No tool calls. Returning final response."
        render_success(response: response_hash)
      end
    rescue External::Client::Error => e
      if e.message.include?("409") && e.message.include?("PENDING_APPROVAL")
        Rails.logger.info "DEBUG: Conflict detected. Attempting to resolve pending approval..."
        messages = client.list_messages(agent_id: params[:agent_id])["messages"] || []
        
        # Look for the last pending tool call or approval request
        pending_msg = messages.reverse.find { |m| m["message_type"] == "tool_call_message" || m["message_type"] == "approval_request_message" }
        
        if pending_msg
          tc = pending_msg["tool_call"] || (pending_msg["tool_calls"] && pending_msg["tool_calls"].first)
          if tc
            normalized_call = {
              id: tc["tool_call_id"] || tc["id"],
              name: tc["name"] || (tc["function"] && tc["function"]["name"]),
              arguments: tc["arguments"] || (tc["function"] && tc["function"]["arguments"])
            }
            Rails.logger.info "DEBUG: Resolving pending call: #{normalized_call[:name]}"
            tool_outputs = External::Executor.new.call([normalized_call])
            render_success(response: client.send_tool_outputs(agent_id: params[:agent_id], tool_outputs: tool_outputs))
            return
          end
        end
      end
      raise e
    rescue StandardError => e
      Rails.logger.error "Letta Controller Error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render_error(error: e.message)
    end
  end
end
