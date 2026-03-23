class PipelinePolicy < ApplicationPolicy
  def index?
    user.super_admin?
  end

  def manage_pipeline?
    user.super_admin?
  end
end
