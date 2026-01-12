# frozen_string_literal: true

module ServiceTools
  class Calculator < BaseTool
    def execute(expression:)
      raise ToolError, "Security violation: Invalid characters in expression." if !expression.match?(/\A[\d\s+\-*\/().]+\z/)

      clean_expression = expression.gsub(/\s+/, "")
      raise ToolError, "Invalid expression format." if clean_expression.match?(/[\+\-\*\/]{2,}/) && !clean_expression.match?(/\*\*|[\+\-\*\/]\(/)

      { expression: expression, result: eval(clean_expression) }
    rescue ZeroDivisionError
      raise ToolError, "Math error: Division by zero"
    end
  end
end
