require 'net/http'
require 'json'
require 'uri'

namespace :letta do
  desc "Register Service Tools with Letta Agent"
  task register_tools: :environment do
    api_url = URI("http://localhost:4000/api/letta/agents/tools")
    
    tools = [
      {
        name: "post_finder",
        description: "Find posts by author name, keyword, or status.",
        source_code: <<~PYTHON
def post_finder(author_name: str = None, keyword: str = None, limit: int = 10, status: str = None):
    """
    Find posts by author name, keyword, or status. Returns a list of posts with title, status, and author.
    
    Args:
        author_name (str): Name of the author to filter by
        keyword (str): Keyword to search in post title
        status (str): Status of the post (e.g. published, draft)
        limit (int): Max number of results to return
    """
    pass
PYTHON
      },
      {
        name: "data_comparator",
        description: "Compare two records from the database.",
        source_code: <<~PYTHON
def data_comparator(table_name: str, id1: int, id2: int):
    """
    Compare two records from the database to find differences in key attributes.
    
    Args:
        table_name (str): Name of the table (e.g. posts, wallets)
        id1 (int): ID of the first record
        id2 (int): ID of the second record
    """
    pass
PYTHON
      },
      {
        name: "statistics_aggregator",
        description: "Calculate statistics for a database column.",
        source_code: <<~PYTHON
def statistics_aggregator(table_name: str, column: str, operation: str = "count"):
    """
    Calculate statistics (sum, avg, count) for a database column.
    
    Args:
        table_name (str): Name of the table
        column (str): Column to aggregate
        operation (str): Operation: count, sum, avg, min, max
    """
    pass
PYTHON
      },
      {
        name: "calculator",
        description: "Perform basic arithmetic calculations.",
        source_code: <<~PYTHON
def calculator(expression: str):
    """
    Perform basic arithmetic calculations.
    
    Args:
        expression (str): Mathematical expression (e.g. 50 * 10)
    """
    pass
PYTHON
      }
    ]

    tools.each do |tool|
      puts "Registering tool: #{tool[:name]}..."
      res = Net::HTTP.post(api_url, tool.to_json, "Content-Type" => "application/json")
      
      if res.is_a?(Net::HTTPSuccess)
        puts "Success: #{tool[:name]}"
      else
        puts "Failed: #{tool[:name]} - Code: #{res.code} - Body: #{res.body}"
      end
    end
    
    puts "Tool registration complete."
  end
end
