# frozen_string_literal: true

class AddMissingIndexes < ActiveRecord::Migration[8.1]
  def change
    add_index :lessons, :teacher_id, name: "index_lessons_on_teacher_id"
    add_index :teacher_students, :teacher_id, name: "index_teacher_students_on_teacher_id"
  end
end
