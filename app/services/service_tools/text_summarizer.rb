# frozen_string_literal: true

module ServiceTools
  class TextSummarizer
    def execute(text:, max_length: 100)
      return { error: "Text is empty" } if text.blank?

      summary = text.truncate(max_length, separator: ' ')
      
      {
        original_length: text.length,
        summary_length: summary.length,
        summary: summary
      }
    rescue StandardError => e
      { error: e.message }
    end
  end
end
