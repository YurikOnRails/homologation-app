require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  test "unread scope returns only unread notifications" do
    notification = notifications(:ana_unread_notification)
    assert_includes Notification.unread, notification
  end

  test "mark_as_read! sets read_at" do
    notification = notifications(:ana_unread_notification)
    assert_nil notification.read_at

    notification.mark_as_read!
    assert_not_nil notification.reload.read_at
    assert notification.read?
  end

  test "read? returns false for unread notification" do
    refute notifications(:ana_unread_notification).read?
  end

  test "title is required" do
    notification = Notification.new(user: users(:student_ana), notifiable: homologation_requests(:ana_equivalencia))
    refute notification.valid?
    assert notification.errors[:title].any?
  end
end
