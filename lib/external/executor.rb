# frozen_string_literal: true

module External
  class Executor
    TOOL_QUERY_LOCAL = "query_local_db"

    def call(tool_calls)
      tool_calls.map do |call|
        output = execute_tool(call[:name], call[:arguments])
        { tool_call_id: call[:id], output: output.to_json, name: call[:name] }
      end
    end

    private

    def execute_tool(name, args)
      if name == TOOL_QUERY_LOCAL
        return External::LocalQuery.new.search(
          query:    args["query"],
          category: args["category"],
          limit:    args["limit"],
        )
      end
      { error: "Tool not found: #{name}" }
    rescue StandardError => e
      { error: e.message }
    end
  end
end
