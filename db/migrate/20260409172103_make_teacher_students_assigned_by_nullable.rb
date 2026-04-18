class MakeTeacherStudentsAssignedByNullable < ActiveRecord::Migration[8.1]
  def change
    change_column_null :teacher_students, :assigned_by, true
  end
end
