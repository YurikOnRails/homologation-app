class CreateHomologationRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :homologation_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :coordinator_id
      t.string :service_type, null: false
      t.string :subject, null: false
      t.text :description
      t.string :identity_card
      t.string :passport
      t.string :education_system
      t.string :studies_finished
      t.string :study_type_spain
      t.string :studies_spain
      t.string :university
      t.string :referral_source
      t.string :language_knowledge
      t.string :language_certificate
      t.boolean :privacy_accepted, null: false, default: false
      t.string :status, null: false, default: "draft"
      t.datetime :status_changed_at
      t.integer :status_changed_by
      t.decimal :payment_amount, precision: 10, scale: 2
      t.datetime :payment_confirmed_at
      t.integer :payment_confirmed_by
      t.string :stripe_payment_intent_id
      t.string :amo_crm_lead_id
      t.datetime :amo_crm_synced_at
      t.text :amo_crm_sync_error
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :homologation_requests, :coordinator_id
    add_index :homologation_requests, :status
    add_index :homologation_requests, [ :user_id, :status ]
    add_index :homologation_requests, :updated_at
    add_index :homologation_requests, :discarded_at
    add_foreign_key :homologation_requests, :users, column: :coordinator_id
    add_foreign_key :homologation_requests, :users, column: :status_changed_by
    add_foreign_key :homologation_requests, :users, column: :payment_confirmed_by
  end
end
