# frozen_string_literal: true

module ConversationSerializer
  extend ActiveSupport::Concern

  private

  def conversation_list_json(c, current_user:)
    last_msg = c.respond_to?(:latest_message) ? c.latest_message : c.messages.max_by(&:created_at)
    other = c.participants.reject { |p| p.id == current_user.id }.first

    {
      id: c.id,
      type: c.homologation_request_id.present? ? "request" : "teacher_student",
      title: c.title,
      otherUser: other ? { id: other.id, name: other.name, avatarUrl: other.avatar_url } : nil,
      lastMessage: last_msg ? { body: last_msg.body.truncate(80), createdAt: last_msg.created_at.iso8601 } : nil,
      unread: c.unread_for?(current_user),
      lastMessageAt: c.last_message_at&.iso8601
    }
  end

  def conversation_detail_json(c, current_user:)
    other = c.participants.reject { |p| p.id == current_user.id }.first

    {
      id: c.id,
      type: c.homologation_request_id.present? ? "request" : "teacher_student",
      title: c.title,
      otherUser: other ? { id: other.id, name: other.name, avatarUrl: other.avatar_url } : nil,
      messages: c.messages.sort_by(&:created_at).map(&:as_json_for_cable)
    }
  end

  def conversation_messages_json(c)
    {
      id: c.id,
      messages: c.messages.order(:created_at).map(&:as_json_for_cable)
    }
  end
end
