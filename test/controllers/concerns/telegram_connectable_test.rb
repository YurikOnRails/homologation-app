require "test_helper"

class TelegramConnectableViaProfilesTest < ActionDispatch::IntegrationTest
  setup do
    @student = create(:user, :student)
    sign_in @student
  end

  test "connect_telegram generates token and redirects to telegram bot" do
    post connect_telegram_profile_path
    assert_response :redirect
    assert @student.reload.telegram_link_token.present?
    assert_match %r{https://t\.me/}, response.location
    assert_includes response.location, @student.telegram_link_token
  end

  test "disconnect_telegram clears chat_id and notification flag" do
    @student.update!(telegram_chat_id: "12345", notification_telegram: true)
    delete disconnect_telegram_profile_path
    @student.reload
    assert_nil @student.telegram_chat_id
    refute @student.notification_telegram?
    assert_redirected_to edit_profile_path
  end
end

class TelegramConnectableViaSettingsTest < ActionDispatch::IntegrationTest
  setup do
    @student = create(:user, :student)
    sign_in @student
  end

  test "connect_telegram via settings generates token and redirects" do
    post settings_connect_telegram_path
    assert_response :redirect
    assert @student.reload.telegram_link_token.present?
    assert_match %r{https://t\.me/}, response.location
  end

  test "disconnect_telegram via settings redirects to notifications settings" do
    @student.update!(telegram_chat_id: "67890", notification_telegram: true)
    delete settings_disconnect_telegram_path
    @student.reload
    assert_nil @student.telegram_chat_id
    refute @student.notification_telegram?
    assert_redirected_to settings_notifications_path
  end
end
