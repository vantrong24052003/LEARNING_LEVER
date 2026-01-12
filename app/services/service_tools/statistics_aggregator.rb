# frozen_string_literal: true

module ServiceTools
  class StatisticsAggregator < BaseTool
    ALLOWED_OPERATIONS = %w[avg sum min max count].freeze
    ALLOWED_TABLES = %w[posts users].freeze
    ALLOWED_COLUMNS = %w[id author_id balance price amount].freeze

    def execute(table_name:, column:, operation: "count")
      operation = operation.to_s.downcase
      return { error: "Invalid operation. Allowed: #{ALLOWED_OPERATIONS.join(', ')}" } if !ALLOWED_OPERATIONS.include?(operation)

      validate_table!(table_name, ALLOWED_TABLES)
      validate_column!(column, ALLOWED_COLUMNS)

      model_class = get_model!(table_name)
      result = model_class.public_send(operation, column)

      { description: "#{operation.capitalize} of #{column} in #{table_name}", value: result }
    end
  end
end
