class RemoveAllIndexes < ActiveRecord::Migration[8.0]
  def change
    remove_index :posts, :user_id if index_exists?(:posts, :user_id)
  end
end
