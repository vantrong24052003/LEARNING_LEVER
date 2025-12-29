# frozen_string_literal: true

module Entries
  class QueryType < Base::BaseObject
    field :posts, resolver: Queries::Post::IndexQuery
    field :post, resolver: Queries::Post::ShowQuery
  end
end
