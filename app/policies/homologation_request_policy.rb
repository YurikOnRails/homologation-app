class HomologationRequestPolicy < ApplicationPolicy
  def index?   = user.student? || user.super_admin?
  def show?    = owner? || user.super_admin?
  def create?  = user.student?
  def update?  = user.super_admin?
  def confirm_payment? = user.super_admin? && record.status == "awaiting_payment"
  def retry_sync? = user.super_admin?
  def download_document? = show?

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.student?
        scope.kept.where(user: user)
      elsif user.super_admin?
        scope.kept
      else
        scope.none
      end
    end
  end

  private

  def owner?
    record.user_id == user.id
  end
end
