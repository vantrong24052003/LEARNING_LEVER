# frozen_string_literal: true

module ServiceTools
  class DataComparator
    def execute(table_name:, id1:, id2:)
      model_class = table_name.classify.safe_constantize
      return { error: "Unknown table: #{table_name}" } if !model_class

      record1 = model_class.find_by(id: id1)
      record2 = model_class.find_by(id: id2)

      return { error: "Record 1 not found" } if !record1
      return { error: "Record 2 not found" } if !record2

      attributes1 = record1.attributes
      attributes2 = record2.attributes

      diff = {}

      whitelist = %w[title status balance name email content body]
      
      (attributes1.keys | attributes2.keys).each do |key|
        next if !whitelist.include?(key)

        val1 = attributes1[key]
        val2 = attributes2[key]
        
        if val1 != val2
          diff[key] = {
            record1: val1,
            record2: val2
          }
        end
      end

      {
        table: table_name,
        compared_items: "Requested IDs (masked)",
        differences_count: diff.size,
        differences: diff.empty? ? "No meaningful differences found" : diff
      }
    rescue StandardError => e
      { error: e.message }
    end
  end
end
