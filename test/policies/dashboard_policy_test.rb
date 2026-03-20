require "test_helper"

class DashboardPolicyTest < ActiveSupport::TestCase
  test "any authenticated user can access dashboard" do
    assert DashboardPolicy.new(users(:student_ana), :dashboard).index?
    assert DashboardPolicy.new(users(:coordinator_maria), :dashboard).index?
    assert DashboardPolicy.new(users(:teacher_ivan), :dashboard).index?
    assert DashboardPolicy.new(users(:super_admin_boss), :dashboard).index?
  end
end
