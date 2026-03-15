class LessonPolicy < ApplicationPolicy
  def index?   = user.present?
  def show?    = own_lesson? || user.coordinator? || user.super_admin?
  def create?  = user.teacher? || user.coordinator? || user.super_admin?
  def update?  = own_lesson? || user.coordinator? || user.super_admin?
  def destroy? = own_lesson? || user.coordinator? || user.super_admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.teacher?
        scope.where(teacher_id: user.id)
      elsif user.student?
        scope.where(student_id: user.id)
      else
        scope.all
      end
    end
  end

  private

  def own_lesson?
    record.teacher_id == user.id || record.student_id == user.id
  end
end
