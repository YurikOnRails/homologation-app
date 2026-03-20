# frozen_string_literal: true

# Delayed digest email for chat messages.
# Instead of emailing on every message, this job fires after 10 minutes
# and sends ONE email summarizing unread messages for a conversation.
#
# Deduplication: multiple jobs may be scheduled for the same user+conversation,
# but only the first to run finds un-emailed notifications. The rest find 0 → skip.
class ChatEmailDigestJob < ApplicationJob
  queue_as :default

  def perform(user_id, conversation_id)
    user = User.find_by(id: user_id)
    return unless user&.notification_email?

    conversation = Conversation.find_by(id: conversation_id)
    return unless conversation

    # Find unread AND un-emailed message notifications for this conversation
    pending = user.notifications
      .unread
      .where(emailed_at: nil, notifiable_type: "Message")
      .where(notifiable_id: Message.where(conversation_id: conversation_id).select(:id))

    return if pending.empty?

    count = pending.count

    # Mark as emailed FIRST to prevent race conditions with other digest jobs
    pending.update_all(emailed_at: Time.current)

    # Send one digest email
    ChatDigestMailer.digest(user, conversation, count).deliver_now
  end
end
