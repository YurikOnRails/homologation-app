require "test_helper"
require "webmock/minitest"

class NotificationJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup do
    WebMock.disable_net_connect!
    WebMock.stub_request(:post, /api\.telegram\.org/).to_return(
      status: 200, body: '{"ok":true}', headers: { "Content-Type" => "application/json" }
    )
    @student = create(:user, :student)
    @request = create(:homologation_request, :submitted, user: @student)
  end

  teardown do
    WebMock.allow_net_connect!
    WebMock.reset!
  end

  test "creates notification record" do
    assert_difference "Notification.count", 1 do
      NotificationJob.perform_now(
        user_id: @student.id,
        title: "Test notification",
        notifiable: @request
      )
    end
  end

  test "sends telegram when user has it enabled" do
    @student.update!(telegram_chat_id: "123456", notification_telegram: true)

    NotificationJob.perform_now(
      user_id: @student.id,
      title: "Test",
      notifiable: @request
    )

    assert_requested :post, /api\.telegram\.org.*\/sendMessage|api\.telegram\.org\/sendMessage/
  end

  test "does not send telegram when user has it disabled" do
    @student.update!(telegram_chat_id: nil, notification_telegram: false)

    NotificationJob.perform_now(
      user_id: @student.id,
      title: "Test",
      notifiable: @request
    )

    assert_not_requested :post, /api\.telegram\.org/
  end

  test "sends immediate email for non-message notifiable" do
    @student.update!(notification_email: true)

    assert_enqueued_emails 1 do
      NotificationJob.perform_now(
        user_id: @student.id,
        title: "Test",
        notifiable: @request
      )
    end
  end

  test "enqueues digest job instead of immediate email for message notifiable" do
    @student.update!(notification_email: true)
    conversation = @request.conversation
    message = create(:message, conversation: conversation, user: @student)

    assert_enqueued_with(job: ChatEmailDigestJob) do
      NotificationJob.perform_now(
        user_id: @student.id,
        title: "Test",
        notifiable: message
      )
    end
  end

  test "does not send email when user has it disabled" do
    @student.update!(notification_email: false)

    assert_enqueued_emails 0 do
      NotificationJob.perform_now(
        user_id: @student.id,
        title: "Test",
        notifiable: @request
      )
    end
  end
end
