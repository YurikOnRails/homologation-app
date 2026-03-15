class ProfilePolicy < ApplicationPolicy
  def show?   = record == user
  def edit?   = record == user
  def update? = record == user
end
