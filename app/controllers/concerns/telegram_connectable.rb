# frozen_string_literal: true

module TelegramConnectable
  extend ActiveSupport::Concern

  def connect_telegram
    authorize @user, :update?, policy_class: ProfilePolicy
    token = SecureRandom.hex(16)
    @user.update!(telegram_link_token: token)
    bot_name = Rails.application.credentials.dig(:telegram, :bot_name) || "HomologationBot"
    redirect_to "https://t.me/#{bot_name}?start=#{token}", allow_other_host: true
  end

  def disconnect_telegram
    authorize @user, :update?, policy_class: ProfilePolicy
    @user.update!(telegram_chat_id: nil, notification_telegram: false)
    redirect_to telegram_disconnect_redirect_path, notice: t("flash.telegram_disconnected")
  end

  private

  def telegram_disconnect_redirect_path
    raise NotImplementedError
  end
end
