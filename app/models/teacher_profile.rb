class TeacherProfile < ApplicationRecord
  belongs_to :user

  validates :level, presence: true, inclusion: { in: %w[junior mid senior native] }
  validates :hourly_rate, presence: true, numericality: { greater_than: 0 }
end
