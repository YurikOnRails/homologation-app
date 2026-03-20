require "test_helper"

class TeacherStudentTest < ActiveSupport::TestCase
  test "teacher-student pair must be unique" do
    duplicate = TeacherStudent.new(
      teacher_id: users(:teacher_ivan).id,
      student_id: users(:student_ana).id,
      assigned_by: users(:coordinator_maria).id
    )
    refute duplicate.valid?
  end

  test "teacher can be assigned multiple students" do
    new_pair = TeacherStudent.new(
      teacher_id: users(:teacher_ivan).id,
      student_id: users(:student_pedro).id,
      assigned_by: users(:coordinator_maria).id
    )
    assert new_pair.valid?
  end
end
