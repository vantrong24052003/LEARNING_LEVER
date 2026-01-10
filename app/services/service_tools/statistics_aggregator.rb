# frozen_string_literal: true

module ServiceTools
  class StatisticsAggregator
    ALLOWED_OPERATIONS = %w[avg sum min max count].freeze

    def execute(table_name:, column:, operation: "count")
      return { error: "Invalid operation. Allowed: #{ALLOWED_OPERATIONS.join(', ')}" } if !ALLOWED_OPERATIONS.include?(operation)
      
      model_class = table_name.classify.safe_constantize
      return { error: "Unknown table: #{table_name}" } if !model_class
      
      return { error: "Column '#{column}' does not exist on table '#{table_name}'" } if !model_class.column_names.include?(column.to_s)

      result = model_class.public_send(operation, column)
      
      {
        description: "#{operation.capitalize} of #{column} for #{table_name}",
        value: result
      }
    rescue StandardError => e
      { error: e.message }
    end
  end
end
