require "test_helper"

class TeachersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @coordinator = create(:user, :coordinator)
    @admin = create(:user, :super_admin)
    @student = create(:user, :student)
    @other_student = create(:user, :student)
    @teacher = create(:user, :teacher)
    @teacher_profile = create(:teacher_profile, user: @teacher)
    @assignment = create(:teacher_student, teacher: @teacher, student: @student, assigned_by: @coordinator.id)
  end

  test "coordinator can list teachers" do
    sign_in @coordinator
    get teachers_path
    assert_response :ok
    assert_equal "teachers/Index", inertia.component
  end

  test "super_admin can list teachers" do
    sign_in @admin
    get teachers_path
    assert_response :ok
    assert_equal "teachers/Index", inertia.component
  end

  test "student cannot access teachers page" do
    sign_in @student
    get teachers_path
    assert_response :forbidden
  end

  test "teacher cannot access teachers page" do
    sign_in @teacher
    get teachers_path
    assert_response :forbidden
  end

  test "coordinator can assign student to teacher" do
    sign_in @coordinator
    assert_difference "TeacherStudent.count", 1 do
      post assign_student_teacher_path(@teacher), params: { student_id: @other_student.id }
    end
    assert_redirected_to teachers_path
  end

  test "coordinator can remove student from teacher" do
    sign_in @coordinator
    assert_difference "TeacherStudent.count", -1 do
      delete remove_student_teacher_path(@teacher), params: { student_id: @student.id }
    end
    assert_redirected_to teachers_path
  end

  test "coordinator can update teacher profile" do
    sign_in @coordinator
    patch teacher_path(@teacher), params: { level: "mid", hourly_rate: 20.0, bio: "Updated bio" }
    assert_redirected_to teachers_path
    assert_equal "mid", @teacher_profile.reload.level
  end
end
