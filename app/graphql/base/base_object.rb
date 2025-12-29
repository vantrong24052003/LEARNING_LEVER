# frozen_string_literal: true

module Base
  class BaseObject < GraphQL::Schema::Object
    field_class Base::BaseField
  end
end
