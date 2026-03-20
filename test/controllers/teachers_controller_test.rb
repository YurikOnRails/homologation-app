require "test_helper"

class TeachersControllerTest < ActionDispatch::IntegrationTest
  test "coordinator can list teachers" do
    sign_in users(:coordinator_maria)
    get teachers_path
    assert_response :ok
    assert_equal "teachers/Index", inertia.component
  end

  test "super_admin can list teachers" do
    sign_in users(:super_admin_boss)
    get teachers_path
    assert_response :ok
    assert_equal "teachers/Index", inertia.component
  end

  test "student cannot access teachers page" do
    sign_in users(:student_ana)
    get teachers_path
    assert_response :forbidden
  end

  test "teacher cannot access teachers page" do
    sign_in users(:teacher_ivan)
    get teachers_path
    assert_response :forbidden
  end

  test "coordinator can assign student to teacher" do
    sign_in users(:coordinator_maria)
    assert_difference "TeacherStudent.count", 1 do
      post assign_student_teacher_path(users(:teacher_ivan)), params: { student_id: users(:student_pedro).id }
    end
    assert_redirected_to teachers_path
  end

  test "coordinator can remove student from teacher" do
    sign_in users(:coordinator_maria)
    assert_difference "TeacherStudent.count", -1 do
      delete remove_student_teacher_path(users(:teacher_ivan)), params: { student_id: users(:student_ana).id }
    end
    assert_redirected_to teachers_path
  end

  test "coordinator can update teacher profile" do
    sign_in users(:coordinator_maria)
    patch teacher_path(users(:teacher_ivan)), params: { level: "mid", hourly_rate: 20.0, bio: "Updated bio" }
    assert_redirected_to teachers_path
    assert_equal "mid", teacher_profiles(:ivan_profile).reload.level
  end
end
