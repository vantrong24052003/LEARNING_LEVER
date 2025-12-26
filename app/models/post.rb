class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy

  enum :status, { draft: 'draft', published: 'published', archived: 'archived' }
end
