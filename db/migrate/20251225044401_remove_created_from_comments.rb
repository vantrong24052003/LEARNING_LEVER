class RemoveCreatedFromComments < ActiveRecord::Migration[8.0]
  def change
    remove_column :comments, :created, :datetime
  end
end
