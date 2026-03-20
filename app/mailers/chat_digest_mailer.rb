# frozen_string_literal: true

class ChatDigestMailer < ApplicationMailer
  def digest(user, conversation, count)
    @user = user
    @conversation = conversation
    @count = count

    I18n.with_locale(@user.locale) do
      mail(
        to: @user.email_address,
        subject: I18n.t("mailers.chat_digest.subject", count: count, title: conversation.title)
      )
    end
  end
end
