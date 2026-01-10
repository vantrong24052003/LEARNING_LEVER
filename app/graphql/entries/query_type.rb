# frozen_string_literal: true

module Entries
  class QueryType < Base::BaseObject
    field :post, resolver: Queries::Post::ShowQuery
    field :posts, resolver: Queries::Post::IndexQuery
  end
end
