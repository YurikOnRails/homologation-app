class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true

  scope :unread, -> { where(read_at: nil) }

  validates :title, presence: true

  def read? = read_at.present?
  def mark_as_read! = update!(read_at: Time.current)
end
