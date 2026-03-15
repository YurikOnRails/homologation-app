class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.references :homologation_request, foreign_key: true, index: { unique: true }
      t.integer :teacher_student_id
      t.datetime :last_message_at
      t.timestamps
    end
    add_index :conversations, :teacher_student_id
    add_index :conversations, :last_message_at
    add_foreign_key :conversations, :teacher_students
  end
end
