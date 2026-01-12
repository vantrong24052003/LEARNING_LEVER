# frozen_string_literal: true

module ServiceTools
  class DataComparator < BaseTool
    ALLOWED_TABLES = %w[posts users].freeze
    ALLOWED_COLUMNS = %w[title status balance name email content body].freeze

    def execute(table_name:, id1:, id2:)
      validate_table!(table_name, ALLOWED_TABLES)
      model_class = get_model!(table_name)

      record1 = find_record!(model_class, id1)
      record2 = find_record!(model_class, id2)

      diff = {}
      (record1.attributes.keys | record2.attributes.keys).each do |key|
        next if !ALLOWED_COLUMNS.include?(key)

        val1, val2 = record1.attributes[key], record2.attributes[key]
        diff[key] = { record1: val1, record2: val2 } if val1 != val2
      end

      { table: table_name, differences_count: diff.size, differences: diff.presence || "No meaningful differences found" }
    end
  end
end
