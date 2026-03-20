require "test_helper"

class RoleTest < ActiveSupport::TestCase
  test "exactly four roles exist" do
    assert_equal 4, Role.count
    assert_equal %w[coordinator student super_admin teacher], Role.pluck(:name).sort
  end

  test "role name must be unique" do
    duplicate = Role.new(name: "student")
    refute duplicate.valid?
  end

  test "role name must be one of the allowed values" do
    invalid = Role.new(name: "hacker")
    refute invalid.valid?
  end
end
