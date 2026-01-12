# frozen_string_literal: true

namespace :letta do
  desc "Register all tools in lib/tasks/letta/tools"
  task sync_tools: :environment do
    client = External::Letta::Client.new
    tools_dir = Rails.root.join("lib", "tasks", "letta", "tools")

    Dir[File.join(tools_dir, "*.rb")].each do |file|
      require file

      method_name = "#{File.basename(file, '.rb')}_definition"

      if Object.respond_to?(method_name, true)
        tool_def = Object.send(method_name)
        Rails.logger.info "Registering tool: #{tool_def[:name]}..."

        begin
          response = client.register_tool(tool_def)
          Rails.logger.info "Success: #{tool_def[:name]}"
          Rails.logger.info "Response: #{response}"
        rescue StandardError => e
          Rails.logger.error "Error registering #{tool_def[:name]}: #{e.message}"
        end
      else
        Rails.logger.warn "Warning: Definition method #{method_name} not found in #{file}"
      end
    end

    Rails.logger.info "Tool synchronization complete."
  end
end
