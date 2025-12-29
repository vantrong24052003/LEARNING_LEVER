# frozen_string_literal: true

module ObjectTypes
  class UserType < Base::BaseObject
    graphql_name "User"

    field :id, ID, null: false
    field :name, String, null: false
    field :email, String, null: false

    field :posts, [ObjectTypes::PostType], null: false
  end
end
