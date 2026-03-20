module Discardable
  extend ActiveSupport::Concern

  included do
    scope :kept, -> { where(discarded_at: nil) }
    scope :discarded, -> { where.not(discarded_at: nil) }
  end

  def discard
    update_columns(discarded_at: Time.current)
  end

  def undiscard
    update_columns(discarded_at: nil)
  end

  def discarded?
    discarded_at.present?
  end
end
