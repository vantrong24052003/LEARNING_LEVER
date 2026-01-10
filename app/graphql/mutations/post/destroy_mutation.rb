# frozen_string_literal: true

module Mutations
  module Post
    class DestroyMutation < BaseMutation
      argument :id, ID, required: true

      field :data, ObjectTypes::PostType, null: true
      field :errors, [String], null: false

      def resolve(id:)
        post = ::Post.find_by(id:)
        return render_not_found("Post") unless post

        if post.destroy
          render_success(post)
        else
          render_error(post.errors.full_messages)
        end
      end
    end
  end
end
