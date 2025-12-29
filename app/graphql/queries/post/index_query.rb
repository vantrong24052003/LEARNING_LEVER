# frozen_string_literal: true

module Queries
  module Post
    class IndexQuery < BaseQuery
      DEFAULT_PAGE = 1
      DEFAULT_LIMIT = 10

      type [ObjectTypes::PostType], null: false
      argument :page, Integer, required: false, default_value: DEFAULT_PAGE
      argument :limit, Integer, required: false, default_value: DEFAULT_LIMIT

      def resolve(page:, limit:)
        ::Post.page(page).per(limit)
      end
    end
  end
end
