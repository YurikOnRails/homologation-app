class ConversationParticipant < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  validates :user_id, uniqueness: { scope: :conversation_id }

  scope :unread, ->(user) {
    where(user: user)
      .joins(:conversation)
      .where("conversation_participants.last_read_at < conversations.last_message_at OR conversation_participants.last_read_at IS NULL")
  }
end
