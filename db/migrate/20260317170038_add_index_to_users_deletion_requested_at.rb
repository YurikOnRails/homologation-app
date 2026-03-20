class AddIndexToUsersDeletionRequestedAt < ActiveRecord::Migration[8.1]
  def change
    add_index :users, :deletion_requested_at
  end
end
