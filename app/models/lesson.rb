class Lesson < ApplicationRecord
  belongs_to :teacher, class_name: "User"
  belongs_to :student, class_name: "User"

  validates :status, inclusion: { in: %w[scheduled completed cancelled] }
  validates :scheduled_at, presence: true
  validates :duration_minutes, numericality: { greater_than: 0 }

  def effective_meeting_link
    meeting_link.presence || teacher.teacher_profile&.permanent_meeting_link
  end

  def meeting_link_ready?
    effective_meeting_link.present?
  end
end
