require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = create(:user, :student)
    @other_student = create(:user, :student)
    @request = create(:homologation_request, :submitted, user: @student)
    @notification = create(:notification, user: @student, notifiable: @request)
  end

  test "user sees own notifications" do
    sign_in @student
    get notifications_path
    assert_response :ok
    assert_equal "notifications/Index", inertia.component
  end

  test "unauthenticated user cannot see notifications" do
    get notifications_path
    assert_redirected_to new_session_path
  end

  test "mark single notification as read and redirect to notifiable" do
    sign_in @student
    assert_nil @notification.read_at
    patch notification_path(@notification)
    assert_response :redirect
    assert @notification.reload.read?
    assert_redirected_to homologation_request_path(@notification.notifiable_id)
  end

  test "cannot mark other user's notification as read" do
    sign_in @other_student
    patch notification_path(@notification)
    assert_response :forbidden
  end

  test "mark all as read works" do
    sign_in @student
    post mark_all_read_notifications_path
    assert_response :redirect
    assert_equal 0, @student.notifications.unread.count
  end
end
