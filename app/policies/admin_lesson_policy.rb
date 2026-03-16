class AdminLessonPolicy < ApplicationPolicy
  def index?
    user.coordinator? || user.super_admin?
  end
end
