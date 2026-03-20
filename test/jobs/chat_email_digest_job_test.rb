require "test_helper"

class ChatEmailDigestJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup do
    @user = users(:coordinator_maria)
    @user.update!(notification_email: true)
    @conversation = conversations(:ana_equivalencia_conversation)
    @message = messages(:ana_message_1)
  end

  test "sends digest email when user has unread un-emailed notifications" do
    Notification.create!(
      user: @user,
      title: "New message",
      notifiable: @message,
      read_at: nil,
      emailed_at: nil
    )

    assert_emails 1 do
      ChatEmailDigestJob.perform_now(@user.id, @conversation.id)
    end
  end

  test "skips email when notification already read" do
    Notification.create!(
      user: @user,
      title: "New message",
      notifiable: @message,
      read_at: Time.current,
      emailed_at: nil
    )

    assert_emails 0 do
      ChatEmailDigestJob.perform_now(@user.id, @conversation.id)
    end
  end

  test "skips email when notification already emailed" do
    Notification.create!(
      user: @user,
      title: "New message",
      notifiable: @message,
      read_at: nil,
      emailed_at: Time.current
    )

    assert_emails 0 do
      ChatEmailDigestJob.perform_now(@user.id, @conversation.id)
    end
  end

  test "skips email when user has email notifications disabled" do
    @user.update!(notification_email: false)

    Notification.create!(
      user: @user,
      title: "New message",
      notifiable: @message,
      read_at: nil,
      emailed_at: nil
    )

    assert_emails 0 do
      ChatEmailDigestJob.perform_now(@user.id, @conversation.id)
    end
  end

  test "marks notifications as emailed after sending" do
    notification = Notification.create!(
      user: @user,
      title: "New message",
      notifiable: @message,
      read_at: nil,
      emailed_at: nil
    )

    ChatEmailDigestJob.perform_now(@user.id, @conversation.id)

    assert_not_nil notification.reload.emailed_at
  end

  test "deduplication: second job finds no pending notifications" do
    Notification.create!(
      user: @user,
      title: "New message",
      notifiable: @message,
      read_at: nil,
      emailed_at: nil
    )

    # First job sends
    assert_emails 1 do
      ChatEmailDigestJob.perform_now(@user.id, @conversation.id)
    end

    # Second job skips — already emailed
    assert_emails 0 do
      ChatEmailDigestJob.perform_now(@user.id, @conversation.id)
    end
  end
end
