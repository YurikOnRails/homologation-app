require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "student can access dashboard" do
    sign_in users(:student_ana)
    get dashboard_path
    assert_response :ok
    assert_equal "dashboard/Index", inertia.component
  end

  test "coordinator is redirected to teachers page" do
    sign_in users(:coordinator_maria)
    get dashboard_path
    assert_redirected_to teachers_path
  end

  test "super_admin can access dashboard" do
    sign_in users(:super_admin_boss)
    get dashboard_path
    assert_response :ok
    assert_equal "dashboard/Index", inertia.component
  end

  test "unauthenticated redirects to login" do
    get dashboard_path
    assert_redirected_to new_session_path
  end
end
