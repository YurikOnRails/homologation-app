require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = create(:user, :student)
    @coordinator = create(:user, :coordinator)
  end

  # --- profile ---

  test "student can view settings profile" do
    sign_in @student
    get settings_profile_path
    assert_response :ok
    assert_equal "settings/Profile", inertia.component
  end

  test "coordinator can view settings profile" do
    sign_in @coordinator
    get settings_profile_path
    assert_response :ok
  end

  test "unauthenticated user is redirected from settings" do
    get settings_profile_path
    assert_redirected_to new_session_path
  end

  test "student can update profile via settings" do
    sign_in @student
    patch settings_profile_path, params: {
      name: "Ana Updated",
      whatsapp: "+34600000001",
      birthday: "2000-01-01",
      country: "ES",
      locale: "es"
    }
    assert_redirected_to settings_profile_path
    assert_equal "Ana Updated", @student.reload.name
  end

  # --- account ---

  test "student can view settings account" do
    sign_in @student
    get settings_account_path
    assert_response :ok
    assert_equal "settings/Account", inertia.component
  end

  test "student cannot change password with wrong current password" do
    sign_in @student
    patch settings_account_path, params: {
      current_password: "wrongpassword",
      password: "newpassword123",
      password_confirmation: "newpassword123"
    }
    assert_redirected_to settings_account_path
  end

  # --- notifications ---

  test "student can view settings notifications" do
    sign_in @student
    get settings_notifications_path
    assert_response :ok
    assert_equal "settings/Notifications", inertia.component
  end

  test "student can update notification preferences" do
    sign_in @student
    patch settings_notifications_path, params: { notification_email: "0" }
    assert_redirected_to settings_notifications_path
    assert_equal false, @student.reload.notification_email
  end

  # --- request_deletion ---

  test "student can request account deletion" do
    sign_in @student
    assert_nil @student.deletion_requested_at
    post settings_request_deletion_path
    assert_redirected_to settings_account_path
    assert_not_nil @student.reload.deletion_requested_at
  end

  test "student cannot request deletion twice" do
    @student.update!(deletion_requested_at: Time.current)
    sign_in @student
    post settings_request_deletion_path
    assert_redirected_to settings_account_path
    # still redirects, no error
  end

  # --- /settings root redirects ---

  test "GET /settings redirects to settings profile" do
    sign_in @student
    get "/settings"
    assert_redirected_to settings_profile_path
  end
end
