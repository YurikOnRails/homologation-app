class AmoCrmToken < ApplicationRecord
  def self.current
    last || raise("No AmoCRM token configured")
  end

  def expired?
    expires_at < 5.minutes.from_now
  end
end
