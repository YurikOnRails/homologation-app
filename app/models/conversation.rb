class Conversation < ApplicationRecord
  belongs_to :homologation_request, optional: true
  belongs_to :teacher_student_link, class_name: "TeacherStudent",
             foreign_key: :teacher_student_id, optional: true

  has_many :messages, dependent: :destroy
  has_many :conversation_participants, dependent: :destroy
  has_many :participants, through: :conversation_participants, source: :user

  validate :must_have_one_association

  def add_participant!(user)
    conversation_participants.find_or_create_by!(user: user)
  end

  private

  def must_have_one_association
    if homologation_request_id.blank? && teacher_student_id.blank?
      errors.add(:base, "must belong to a homologation request or teacher-student pair")
    end
  end
end
