# frozen_string_literal: true

module Entries
  class MutationType < Base::BaseObject
    field :create_post, mutation: Mutations::Post::CreateMutation
    field :update_post, mutation: Mutations::Post::UpdateMutation
    field :delete_post, mutation: Mutations::Post::DestroyMutation
  end
end
