# frozen_string_literal: true

module ObjectTypes
  class PostType < Base::BaseObject
    graphql_name "Post"

    field :id, ID, null: false
    field :title, String, null: false
    field :status, String, null: false

    field :user, ObjectTypes::UserType, null: false
  end
end
