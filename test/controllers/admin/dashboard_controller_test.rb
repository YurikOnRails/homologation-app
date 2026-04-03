require "test_helper"

module Admin
  class DashboardControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = create(:user, :super_admin)
      @coordinator = create(:user, :coordinator)
      @student = create(:user, :student)
    end

    test "super admin can access dashboard" do
      sign_in @admin
      get admin_root_path
      assert_response :ok
      assert_equal "admin/Dashboard", inertia.component
    end

    test "coordinator cannot access admin dashboard" do
      sign_in @coordinator
      get admin_root_path
      assert_response :forbidden
    end

    test "student cannot access admin dashboard" do
      sign_in @student
      get admin_root_path
      assert_response :forbidden
    end

    test "admin dashboard props include stats" do
      sign_in @admin
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
      sign_in @admin
      get admin_root_path
      assert_response :ok
      props = inertia.props
      assert props[:requestsByMonth].is_a?(Hash)
      assert props[:requestsByStatus].is_a?(Hash)
      assert props[:recentRequests].is_a?(Array)
    end
  end
end
