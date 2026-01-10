# frozen_string_literal: true

module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    field_class Base::BaseField
    input_object_class Base::BaseInputObject
    object_class Base::BaseObject

    def resolve(*)
      super
    rescue ArgumentError => e
      handle_argument_error(e)
    rescue ActiveRecord::RecordNotFound => e
      handle_record_not_found(e)
    end

    private

    def render_success(resource)
      { data: resource, errors: [] }
    end

    def render_error(messages)
      errors = Array(messages)
      { data: nil, errors: }
    end

    def handle_argument_error(exception)
      render_error(exception.message)
    end

    def handle_record_not_found(exception)
      render_error(exception.message)
    end
  end
end
