require "test_helper"

module Admin
  class LessonsControllerTest < ActionDispatch::IntegrationTest
    test "coordinator can access admin lessons" do
      sign_in users(:coordinator_maria)
      get admin_lessons_path
      assert_response :ok
      assert_equal "admin/Lessons", inertia.component
    end

    test "super_admin can access admin lessons" do
      sign_in users(:super_admin_boss)
      get admin_lessons_path
      assert_response :ok
      assert_equal "admin/Lessons", inertia.component
    end

    test "student cannot access admin lessons" do
      sign_in users(:student_ana)
      get admin_lessons_path
      assert_response :forbidden
    end

    test "teacher cannot access admin lessons" do
      sign_in users(:teacher_ivan)
      get admin_lessons_path
      assert_response :forbidden
    end

    test "admin lessons props include lessons array" do
      sign_in users(:coordinator_maria)
      get admin_lessons_path
      assert_response :ok
      props = inertia.props
      assert props[:lessons].is_a?(Array)
    end
  end
end
