# frozen_string_literal: true

module External
  module Letta
    class Executor
      def call(tool_calls)
        tool_calls.map do |call|
          output = execute_tool(call[:name], call[:arguments])
          { tool_call_id: call[:id], output: output.to_json, name: call[:name] }
        end
      end

      private

      def execute_tool(name, args)
        class_name = "ServiceTools::#{name.classify}"
        tool_class = class_name.safe_constantize

        if !tool_class
          Rails.logger.error "[Tool Error] Unknown tool: #{name}"
          return { error: "Unknown tool: #{name}" }
        end

        tool_class.new.execute(**args.deep_symbolize_keys)
      rescue ServiceTools::BaseTool::ToolError => e
        { error: e.message }
      rescue StandardError => e
        Rails.logger.error "[Tool Error] Unexpected failure in #{name}: #{e.message}"
        { error: "Unexpected system error in tool #{name}" }
      end
    end
  end
end
