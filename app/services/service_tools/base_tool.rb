# frozen_string_literal: true

module ServiceTools
  class BaseTool
    class ToolError < StandardError; end

    def execute(**_args)
      raise NotImplementedError, "Subclasses must implement #execute"
    end

    protected

    def validate_table!(table_name, allowed_tables)
      return if allowed_tables.include?(table_name.to_s.downcase)

      raise ToolError, "Access denied to table: #{table_name}"
    end

    def validate_column!(column, allowed_columns)
      return if allowed_columns.include?(column.to_s.downcase)

      raise ToolError, "Access denied to column: #{column}"
    end

    def find_record!(model_class, id)
      record = model_class.find_by(id: id)
      return record if record

      raise ToolError, "#{model_class.name.humanize} with ID #{id} not found"
    end

    def get_model!(table_name)
      model_class = table_name.classify.safe_constantize
      return model_class if model_class

      raise ToolError, "System error: Model #{table_name.classify} not found"
    end
  end
end
