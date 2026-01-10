# frozen_string_literal: true

module External
  module Letta
    class Executor
      TOOL_QUERY_LOCAL = "query_local_db"
      TOOL_GENERIC_QUERY = "generic_data_query"
      TOOL_FAST_QUERY = "fast_data_query"

      def call(tool_calls)
        tool_calls.map do |call|
          output = execute_tool(call[:name], call[:arguments])
          { tool_call_id: call[:id], output: output.to_json, name: call[:name] }
        end
      end

      private

      def execute_tool(name, args)
        class_name = nil
        
        # Handle manual map if names don't match perfectly
        if name == TOOL_GENERIC_QUERY || name == TOOL_FAST_QUERY
           class_name = "ServiceTools::PostFinder"
        elsif name == TOOL_QUERY_LOCAL
           class_name = "ServiceTools::PostFinder"
        else
           class_name = "ServiceTools::#{name.classify}"
        end
        
        tool_class = class_name.safe_constantize

        if !tool_class
          return { error: "Tool not found: #{name} (Class #{class_name} not found)" }
        end

        symbolized_args = args.deep_symbolize_keys

        tool_instance = tool_class.new
        
        if tool_instance.respond_to?(:execute)
          tool_instance.execute(**symbolized_args)
        else
           { error: "Tool class #{class_name} does not have an execute method" }
        end
      rescue ArgumentError => e
        { error: "Invalid arguments for tool #{name}: #{e.message}" }
      rescue StandardError => e
        { error: "Tool execution failed: #{e.message}" }
      end
    end
  end
end
