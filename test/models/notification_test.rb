require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  setup do
    @student = create(:user, :student)
    @request = create(:homologation_request, :submitted, user: @student)
    @notification = create(:notification, user: @student, notifiable: @request)
  end

  test "unread scope returns only unread notifications" do
    assert_includes Notification.unread, @notification
  end

  test "mark_as_read! sets read_at" do
    assert_nil @notification.read_at

    @notification.mark_as_read!
    assert_not_nil @notification.reload.read_at
    assert @notification.read?
  end

  test "read? returns false for unread notification" do
    refute @notification.read?
  end

  test "title is required" do
    notification = Notification.new(user: @student, notifiable: @request)
    refute notification.valid?
    assert notification.errors[:title].any?
  end
end
