class ChatsPolicy < ApplicationPolicy
  def index? = user.super_admin?
  def show?  = user.super_admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.super_admin?
        scope.all
      else
        scope.none
      end
    end
  end
end
