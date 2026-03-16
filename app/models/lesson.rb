class Lesson < ApplicationRecord
  belongs_to :teacher, class_name: "User"
  belongs_to :student, class_name: "User"

  validates :status, inclusion: { in: %w[scheduled completed cancelled] }
  validates :scheduled_at, presence: true
  validates :duration_minutes, numericality: { greater_than: 0 }
  validate :scheduled_at_must_be_future, on: :create
  validate :student_must_be_assigned_to_teacher

  def effective_meeting_link
    meeting_link.presence || teacher.teacher_profile&.permanent_meeting_link
  end

  def meeting_link_ready?
    effective_meeting_link.present?
  end

  private

  def scheduled_at_must_be_future
    return if scheduled_at.blank?
    errors.add(:scheduled_at, :must_be_future) if scheduled_at < Time.current
  end

  def student_must_be_assigned_to_teacher
    return if teacher_id.blank? || student_id.blank?
    unless TeacherStudent.exists?(teacher_id: teacher_id, student_id: student_id)
      errors.add(:student_id, :not_assigned_to_teacher)
    end
  end
end
