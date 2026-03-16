require "test_helper"

class ProfilePolicyTest < ActiveSupport::TestCase
  test "user can view own profile" do
    ana = users(:student_ana)
    assert ProfilePolicy.new(ana, ana).show?
    assert ProfilePolicy.new(ana, ana).edit?
    assert ProfilePolicy.new(ana, ana).update?
  end

  test "user cannot view another user's profile" do
    ana = users(:student_ana)
    pedro = users(:student_pedro)
    refute ProfilePolicy.new(ana, pedro).show?
    refute ProfilePolicy.new(ana, pedro).edit?
    refute ProfilePolicy.new(ana, pedro).update?
  end
end
