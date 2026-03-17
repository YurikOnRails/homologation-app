class NotificationJob < ApplicationJob
  queue_as :default

  CHAT_DIGEST_DELAY = 10.minutes

  def perform(user_id:, title:, body: nil, notifiable:)
    user = User.find(user_id)

    # 1. Always create in-app notification
    notification = Notification.create!(
      user_id: user_id, title: title, body: body, notifiable: notifiable
    )

    # 2. Always broadcast to Action Cable (real-time bell update)
    NotificationChannel.broadcast_to(user, {
      id: notification.id, title: title, body: body,
      createdAt: notification.created_at.iso8601,
      unreadCount: user.notifications.unread.count
    })

    # 3. Email — chat messages get a delayed digest, everything else is immediate
    if user.notification_email?
      if notifiable.is_a?(Message)
        ChatEmailDigestJob.set(wait: CHAT_DIGEST_DELAY)
          .perform_later(user.id, notifiable.conversation_id)
      else
        NotificationMailer.notify(notification).deliver_later
      end
    end

    # 4. Telegram (if user connected and enabled) — skip for chat messages (covered by digest)
    if user.notification_telegram? && user.telegram_chat_id.present? && !notifiable.is_a?(Message)
      TelegramClient.new.send_message(
        user.telegram_chat_id,
        "<b>#{title}</b>\n#{body}"
      )
    end
  end
end
