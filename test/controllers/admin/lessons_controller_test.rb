require "test_helper"

module Admin
  class LessonsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = create(:user, :super_admin)
      @coordinator = create(:user, :coordinator)
      @student = create(:user, :student)
      @teacher = create(:user, :teacher)
    end

    test "coordinator can access admin lessons" do
      sign_in @coordinator
      get admin_lessons_path
      assert_response :ok
      assert_equal "admin/Lessons", inertia.component
    end

    test "super_admin can access admin lessons" do
      sign_in @admin
      get admin_lessons_path
      assert_response :ok
      assert_equal "admin/Lessons", inertia.component
    end

    test "student cannot access admin lessons" do
      sign_in @student
      get admin_lessons_path
      assert_response :forbidden
    end

    test "teacher cannot access admin lessons" do
      sign_in @teacher
      get admin_lessons_path
      assert_response :forbidden
    end

    test "admin lessons props include lessons array" do
      sign_in @coordinator
      get admin_lessons_path
      assert_response :ok
      props = inertia.props
      assert props[:lessons].is_a?(Array)
    end
  end
end
