class CreateLessons < ActiveRecord::Migration[8.1]
  def change
    create_table :lessons do |t|
      t.integer :teacher_id, null: false
      t.integer :student_id, null: false
      t.datetime :scheduled_at, null: false
      t.integer :duration_minutes, null: false, default: 60
      t.string :meeting_link
      t.string :status, null: false, default: "scheduled"
      t.text :notes
      t.timestamps
    end
    add_index :lessons, [ :teacher_id, :scheduled_at ]
    add_index :lessons, [ :student_id, :scheduled_at ]
    add_index :lessons, :status
    add_foreign_key :lessons, :users, column: :teacher_id
    add_foreign_key :lessons, :users, column: :student_id
  end
end
