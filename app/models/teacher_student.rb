class TeacherStudent < ApplicationRecord
  # Table has only created_at, no updated_at
  self.record_timestamps = false
  before_create { self.created_at = Time.current if has_attribute?(:created_at) }

  belongs_to :teacher, class_name: "User"
  belongs_to :student, class_name: "User"

  has_one :conversation, dependent: :destroy

  validates :teacher_id, uniqueness: { scope: :student_id }
end
