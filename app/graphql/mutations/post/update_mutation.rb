# frozen_string_literal: true

module Mutations
  module Post
    class UpdateMutation < BaseMutation
      argument :id, ID, required: true
      argument :title, String, required: false
      argument :status, String, required: false

      field :data, ObjectTypes::PostType, null: true
      field :errors, [ String ], null: false

      def resolve(id:, **attrs)
        post = ::Post.find_by(id: id)
        return render_not_found("Post") unless post

        if post.update(attrs)
          render_success(post)
        else
          render_error(post.errors.full_messages)
        end
      end
    end
  end
end
