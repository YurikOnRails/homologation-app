class CreateTeacherStudents < ActiveRecord::Migration[8.1]
  def change
    create_table :teacher_students do |t|
      t.integer :teacher_id, null: false
      t.integer :student_id, null: false
      t.integer :assigned_by, null: false
      t.datetime :created_at, null: false
    end
    add_index :teacher_students, [ :teacher_id, :student_id ], unique: true
    add_index :teacher_students, :student_id
    add_foreign_key :teacher_students, :users, column: :teacher_id
    add_foreign_key :teacher_students, :users, column: :student_id
    add_foreign_key :teacher_students, :users, column: :assigned_by
  end
end
