namespace :letta do
  desc "Register tools with Letta Server"
  task register_tool: :environment do
    client = External::Client.new()

    tool_def = {
      sourceCode: <<~PYTHON,
        def query_local_db(query: str = None, category: str = None):
            \"\"\"
            Tìm kiếm sản phẩm hoặc thông tin trong database của khách hàng.

            Args:
                query (str): Từ khóa tìm kiếm tiêu đề bài viết (tùy chọn).
                category (str): Lọc theo trạng thái bài viết: draft, published, archived (tùy chọn).
            \"\"\"
            return \"CLIENT_SIDE_EXECUTION\"
      PYTHON
      defaultRequiresApproval: true
    }

    schema = tool_def # Full content for POST /agents/tools as per Phase 1 doc

    puts "Registering tool: #{tool_def[:name]}..."
    begin
        response = client.register_tool(schema)
        puts "Success: #{response}"
    rescue => e
        puts "Error: #{e.message}"
    end
  end
end
