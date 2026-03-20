module UserSerializer
  private

  def profile_json(u)
    { id: u.id, name: u.name, email: u.email_address, phone: u.phone, whatsapp: u.whatsapp,
      birthday: u.birthday&.iso8601, country: u.country, locale: u.locale,
      isMinor: u.is_minor, guardianName: u.guardian_name, guardianEmail: u.guardian_email,
      guardianPhone: u.guardian_phone, guardianWhatsapp: u.guardian_whatsapp,
      profileComplete: u.profile_complete?,
      notificationEmail: u.notification_email?,
      notificationTelegram: u.notification_telegram?,
      telegramConnected: u.telegram_chat_id.present? }
  end

  def notifications_json(u)
    { notificationEmail: u.notification_email?,
      notificationTelegram: u.notification_telegram?,
      telegramConnected: u.telegram_chat_id.present? }
  end
end
