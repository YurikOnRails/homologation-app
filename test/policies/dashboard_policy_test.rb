require "test_helper"

class DashboardPolicyTest < ActiveSupport::TestCase
  test "any authenticated user can access dashboard" do
    assert DashboardPolicy.new(create(:user, :student), :dashboard).index?
    assert DashboardPolicy.new(create(:user, :coordinator), :dashboard).index?
    assert DashboardPolicy.new(create(:user, :teacher), :dashboard).index?
    assert DashboardPolicy.new(create(:user, :super_admin), :dashboard).index?
  end
end
