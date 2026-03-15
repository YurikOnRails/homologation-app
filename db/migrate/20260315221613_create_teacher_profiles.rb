class CreateTeacherProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :teacher_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.text :bio
      t.string :permanent_meeting_link
      t.string :level, null: false
      t.decimal :hourly_rate, null: false, precision: 8, scale: 2
      t.timestamps
    end
  end
end
