class AddFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :name, :string, null: false, default: ""
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :avatar_url, :string
    add_column :users, :phone, :string
    add_column :users, :whatsapp, :string
    add_column :users, :birthday, :date
    add_column :users, :country, :string
    add_column :users, :locale, :string, default: "es"
    add_column :users, :is_minor, :boolean, null: false, default: false
    add_column :users, :guardian_name, :string
    add_column :users, :guardian_email, :string
    add_column :users, :guardian_phone, :string
    add_column :users, :guardian_whatsapp, :string
    add_column :users, :guardian_user_id, :integer
    add_column :users, :telegram_chat_id, :string
    add_column :users, :telegram_link_token, :string
    add_column :users, :notification_telegram, :boolean, null: false, default: false
    add_column :users, :notification_email, :boolean, null: false, default: true
    add_column :users, :amo_crm_contact_id, :string
    add_column :users, :privacy_accepted_at, :datetime
    add_column :users, :discarded_at, :datetime

    add_index :users, [ :provider, :uid ], unique: true
    add_index :users, :guardian_user_id
    add_index :users, :discarded_at
  end
end
