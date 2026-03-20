require "test_helper"

class TeacherPolicyTest < ActiveSupport::TestCase
  test "coordinator can manage teachers" do
    policy = TeacherPolicy.new(users(:coordinator_maria), :teacher)
    assert policy.index?
    assert policy.update?
    assert policy.assign_student?
    assert policy.remove_student?
  end

  test "super_admin can manage teachers" do
    policy = TeacherPolicy.new(users(:super_admin_boss), :teacher)
    assert policy.index?
    assert policy.assign_student?
  end

  test "teacher cannot manage other teachers" do
    policy = TeacherPolicy.new(users(:teacher_ivan), :teacher)
    refute policy.index?
    refute policy.assign_student?
  end

  test "student cannot manage teachers" do
    policy = TeacherPolicy.new(users(:student_ana), :teacher)
    refute policy.index?
    refute policy.update?
  end
end
