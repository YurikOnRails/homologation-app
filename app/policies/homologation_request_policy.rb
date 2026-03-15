class HomologationRequestPolicy < ApplicationPolicy
  def index?   = user.present?
  def show?    = owner? || coordinator_or_admin?
  def create?  = user.student?
  def update?  = coordinator_or_admin?
  def confirm_payment? = coordinator_or_admin? && record.status == "awaiting_payment"
  def download_document? = show?

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.student?
        scope.kept.where(user: user)
      elsif user.coordinator? || user.super_admin?
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

  def coordinator_or_admin?
    user.coordinator? || user.super_admin?
  end
end
