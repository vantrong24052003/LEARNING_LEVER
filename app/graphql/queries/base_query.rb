# frozen_string_literal: true

module Queries
  class BaseQuery < GraphQL::Schema::Resolver
    def resolve(*args)
      super(*args)
    rescue ArgumentError => e
      handle_argument_error(e)
    rescue ActiveRecord::RecordNotFound => e
      handle_record_not_found(e)
    end

    private

    def handle_record_not_found(exception)
      raise GraphQL::ExecutionError, exception.message
    end

    def handle_argument_error(exception)
      raise GraphQL::ExecutionError, exception.message
    end
  end
end
