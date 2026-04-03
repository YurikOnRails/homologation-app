require "test_helper"

class TeacherStudentTest < ActiveSupport::TestCase
  setup do
    @teacher = create(:user, :teacher)
    @student = create(:user, :student)
    @other_student = create(:user, :student)
    @coordinator = create(:user, :coordinator)
    @assignment = create(:teacher_student, teacher: @teacher, student: @student, assigned_by: @coordinator.id)
  end

  test "teacher-student pair must be unique" do
    duplicate = TeacherStudent.new(
      teacher_id: @teacher.id,
      student_id: @student.id,
      assigned_by: @coordinator.id
    )
    refute duplicate.valid?
  end

  test "teacher can be assigned multiple students" do
    new_pair = TeacherStudent.new(
      teacher_id: @teacher.id,
      student_id: @other_student.id,
      assigned_by: @coordinator.id
    )
    assert new_pair.valid?
  end
end
