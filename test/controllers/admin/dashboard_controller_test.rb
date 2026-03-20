require "test_helper"

module Admin
  class DashboardControllerTest < ActionDispatch::IntegrationTest
    test "super admin can access dashboard" do
      sign_in users(:super_admin_boss)
      get admin_root_path
      assert_response :ok
      assert_equal "admin/Dashboard", inertia.component
    end

    test "coordinator cannot access admin dashboard" do
      sign_in users(:coordinator_maria)
      get admin_root_path
      assert_response :forbidden
    end

    test "student cannot access admin dashboard" do
      sign_in users(:student_ana)
      get admin_root_path
      assert_response :forbidden
    end

    test "admin dashboard props include stats" do
      sign_in users(:super_admin_boss)
      get admin_root_path
      assert_response :ok
      props = inertia.props
      assert props[:stats].is_a?(Hash)
      assert props[:stats].key?(:totalRequests)
      assert props[:stats].key?(:openRequests)
      assert props[:stats].key?(:awaitingPayment)
      assert props[:stats].key?(:resolved)
    end

    test "admin dashboard props include charts data" do
      sign_in users(:super_admin_boss)
      get admin_root_path
      assert_response :ok
      props = inertia.props
      assert props[:requestsByMonth].is_a?(Hash)
      assert props[:requestsByStatus].is_a?(Hash)
      assert props[:recentRequests].is_a?(Array)
    end
  end
end
