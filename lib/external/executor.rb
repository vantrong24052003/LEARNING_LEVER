module External
  class Executor
    TOOL_QUERY_LOCAL = "query_local_db"

    def call(tool_calls)
      tool_calls.map do |call|
        args = call[:arguments].is_a?(String) ? JSON.parse(call[:arguments]) : call[:arguments]
        output = execute_tool(call[:name], args)
        { tool_call_id: call[:id], output: output.to_json, name: call[:name] }
      end
    end

    private

    def execute_tool(name, args)
      return External::LocalQuery.new.search(query: args["query"], category: args["category"]) if name == TOOL_QUERY_LOCAL
      
      { error: "Tool not found: #{name}" }
    rescue StandardError => e
      { error: e.message }
    end
  end
end
