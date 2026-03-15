class UserPolicy < ApplicationPolicy
  def index?   = user.super_admin?
  def show?    = user.super_admin?
  def create?  = user.super_admin?
  def update?  = user.super_admin?
  def destroy? = user.super_admin?
  def manage?  = user.super_admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.super_admin? ? scope.all : scope.none
    end
  end
end
