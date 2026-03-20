require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "privacy policy page is accessible without authentication" do
    get privacy_policy_path
    assert_response :ok
    assert_equal "PrivacyPolicy", inertia.component
  end

  test "privacy policy page is accessible when authenticated" do
    sign_in users(:student_ana)
    get privacy_policy_path
    assert_response :ok
    assert_equal "PrivacyPolicy", inertia.component
  end
end
