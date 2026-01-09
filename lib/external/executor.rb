module External
  class Executor
    TOOL_QUERY_LOCAL = "query_local_db"

    def call(tool_calls)
      tool_calls.map do |call|
        output = execute_tool(call[:name], JSON.parse(call[:arguments].to_s))
        { tool_call_id: call[:id], output: output.to_json }
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
