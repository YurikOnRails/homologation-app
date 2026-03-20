class CreateAmoCrmTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :amo_crm_tokens do |t|
      t.text :access_token, null: false
      t.text :refresh_token, null: false
      t.datetime :expires_at, null: false
      t.timestamps
    end
  end
end
