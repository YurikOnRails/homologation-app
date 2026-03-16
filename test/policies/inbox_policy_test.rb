require "test_helper"

class InboxPolicyTest < ActiveSupport::TestCase
  test "coordinator can access inbox" do
    policy = InboxPolicy.new(users(:coordinator_maria), :inbox)
    assert policy.index?
    assert policy.show?
  end

  test "super_admin can access inbox" do
    assert InboxPolicy.new(users(:super_admin_boss), :inbox).index?
  end

  test "student cannot access inbox" do
    policy = InboxPolicy.new(users(:student_ana), :inbox)
    refute policy.index?
    refute policy.show?
  end

  test "teacher cannot access inbox" do
    refute InboxPolicy.new(users(:teacher_ivan), :inbox).index?
  end
end
