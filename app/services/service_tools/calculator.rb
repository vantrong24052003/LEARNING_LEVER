# frozen_string_literal: true

module ServiceTools
  class Calculator
    def execute(expression:)
      return { error: "Invalid characters in expression. Only numbers and basic math operators allowed." } if !expression.match?(/\A[\d\s+\-*\/().]+\z/)
      
      result = eval(expression)
      
      {
        expression: expression,
        result: result
      }
    rescue StandardError => e
      { error: "Calculation failed: #{e.message}" }
    end
  end
end
