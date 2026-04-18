class AddPurgeScheduledAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :purge_scheduled_at, :datetime
  end
end
