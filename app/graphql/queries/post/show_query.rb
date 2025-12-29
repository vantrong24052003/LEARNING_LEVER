# frozen_string_literal: true

module Queries
  module Post
    class ShowQuery < BaseQuery
      type ObjectTypes::PostType, null: true
      argument :id, ID, required: true

      def resolve(id:)
        find_post(id)
      end

      private

      def find_post(id)
        ::Post.find(id)
      end
    end
  end
end
