require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "student can access dashboard" do
    sign_in users(:student_ana)
    get root_path
    assert_response :ok
    assert_equal "dashboard/Index", inertia.component
  end

  test "coordinator can access dashboard" do
    sign_in users(:coordinator_maria)
    get root_path
    assert_response :ok
    assert_equal "dashboard/Index", inertia.component
  end

  test "unauthenticated redirects to login" do
    get root_path
    assert_redirected_to new_session_path
  end
end
