require "test_helper"

class UserPolicyTest < ActiveSupport::TestCase
  setup do
    @boss = create(:user, :super_admin)
    @maria = create(:user, :coordinator)
    @ana = create(:user, :student)
    @target = create(:user, :student)
  end

  test "super_admin can manage users" do
    policy = UserPolicy.new(@boss, @target)
    assert policy.index?
    assert policy.show?
    assert policy.create?
    assert policy.update?
    assert policy.destroy?
  end

  test "coordinator cannot manage users" do
    policy = UserPolicy.new(@maria, @target)
    refute policy.index?
    refute policy.create?
    refute policy.update?
  end

  test "student cannot manage users" do
    policy = UserPolicy.new(@ana, @target)
    refute policy.index?
    refute policy.show?
  end

  test "super_admin scope returns all users" do
    scope = UserPolicy::Scope.new(@boss, User).resolve
    assert_equal User.count, scope.count
  end

  test "non-admin scope returns nothing" do
    scope = UserPolicy::Scope.new(@maria, User).resolve
    assert_empty scope
  end
end
