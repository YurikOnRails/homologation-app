require "test_helper"

module Admin
  class UsersControllerTest < ActionDispatch::IntegrationTest
    test "super admin can list users" do
      sign_in users(:super_admin_boss)
      get admin_users_path
      assert_response :ok
      assert_equal "admin/Users", inertia.component
    end

    test "super admin can create user" do
      sign_in users(:super_admin_boss)
      assert_difference "User.count", 1 do
        post admin_users_path, params: {
          user: { name: "New User", email_address: "new@test.com", password: "password123" }
        }
      end
    end

    test "super admin can assign role" do
      sign_in users(:super_admin_boss)
      post assign_role_admin_user_path(users(:student_ana)), params: { role_name: "coordinator" }
      assert users(:student_ana).reload.coordinator?
    end

    test "super admin can remove role" do
      sign_in users(:super_admin_boss)
      delete remove_role_admin_user_path(users(:student_ana)), params: { role_name: "student" }
      refute users(:student_ana).reload.student?
    end

    test "coordinator cannot manage users" do
      sign_in users(:coordinator_maria)
      get admin_users_path
      assert_response :forbidden
    end

    test "super admin can edit user" do
      sign_in users(:super_admin_boss)
      get edit_admin_user_path(users(:student_ana))
      assert_response :ok
    end

    test "super admin can update user" do
      sign_in users(:super_admin_boss)
      patch admin_user_path(users(:student_ana)), params: {
        user: { name: "Updated Name" }
      }
      assert_equal "Updated Name", users(:student_ana).reload.name
    end

    test "super admin can deactivate user (soft delete)" do
      sign_in users(:super_admin_boss)
      delete admin_user_path(users(:student_pedro))
      assert users(:student_pedro).reload.discarded?
    end

    test "users list props include users array" do
      sign_in users(:super_admin_boss)
      get admin_users_path
      assert_response :ok
      props = inertia.props
      assert props[:users].is_a?(Array)
    end
  end
end
