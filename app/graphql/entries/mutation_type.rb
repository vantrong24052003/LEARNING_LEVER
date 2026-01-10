# frozen_string_literal: true

module Entries
  class MutationType < Base::BaseObject
    field :create_post, mutation: Mutations::Post::CreateMutation
    field :delete_post, mutation: Mutations::Post::DestroyMutation
    field :update_post, mutation: Mutations::Post::UpdateMutation
  end
end
