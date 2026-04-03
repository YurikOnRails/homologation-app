require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = create(:user, :student)
  end

  test "student can view profile" do
    sign_in @student
    get edit_profile_path
    assert_response :ok
    assert_equal "profile/Edit", inertia.component
  end

  test "student can update profile" do
    sign_in @student
    patch profile_path, params: { whatsapp: "+34999999999", country: "ES" }
    assert_redirected_to dashboard_path
    assert_equal "+34999999999", @student.reload.whatsapp
  end

  test "incomplete profile redirects to edit" do
    @student.update_columns(whatsapp: nil)
    sign_in @student
    get dashboard_path
    assert_redirected_to edit_profile_path
  end

  test "locale update saves to user" do
    sign_in @student
    patch profile_path, params: { locale: "ru" }
    assert_equal "ru", @student.reload.locale
  end

  test "minor fields are saved" do
    sign_in @student
    patch profile_path, params: { is_minor: true, guardian_name: "Mama", guardian_email: "mama@test.com", guardian_phone: "+34600111222" }
    reloaded = @student.reload
    assert reloaded.is_minor?
    assert_equal "Mama", reloaded.guardian_name
  end

  test "connect_telegram generates token and redirects to bot" do
    sign_in @student
    post connect_telegram_profile_path
    assert @student.reload.telegram_link_token.present?
    assert_response :redirect
  end

  test "disconnect_telegram clears chat_id" do
    @student.update!(telegram_chat_id: "123", notification_telegram: true)
    sign_in @student
    delete disconnect_telegram_profile_path
    assert_nil @student.reload.telegram_chat_id
    refute @student.notification_telegram?
  end
end
