class RemoveCreatedFromPosts < ActiveRecord::Migration[8.0]
  def change
    remove_column :posts, :created, :datetime
  end
end
