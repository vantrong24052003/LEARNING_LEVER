# frozen_string_literal: true

module Mutations
  module Post
    class CreateMutation < BaseMutation
      argument :status, String, required: true
      argument :title, String, required: true
      argument :user_id, ID, required: true

      field :data, ObjectTypes::PostType, null: true
      field :errors, [String], null: false

      def resolve(title:, status:, user_id:)
        user = find_user(user_id)

        post = user.posts.new(title:, status:)

        if post.save
          render_success(post)
        else
          render_error(post.errors.full_messages)
        end
      end

      private

      def find_user(id)
        ::User.find(id)
      end
    end
  end
end
