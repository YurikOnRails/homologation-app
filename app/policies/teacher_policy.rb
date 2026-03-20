# Headless policy — authorize :teacher, :index?
class TeacherPolicy < ApplicationPolicy
  def index?          = user.coordinator? || user.super_admin?
  def update?         = user.coordinator? || user.super_admin?
  def assign_student? = user.coordinator? || user.super_admin?
  def remove_student? = user.coordinator? || user.super_admin?

  class Scope < ApplicationPolicy::Scope
    def resolve = scope.none
  end
end
