require "test_helper"

class TeacherPolicyTest < ActiveSupport::TestCase
  setup do
    @coordinator = create(:user, :coordinator)
    @admin = create(:user, :super_admin)
    @teacher = create(:user, :teacher)
    @student = create(:user, :student)
  end

  test "coordinator can manage teachers" do
    policy = TeacherPolicy.new(@coordinator, :teacher)
    assert policy.index?
    assert policy.update?
    assert policy.assign_student?
    assert policy.remove_student?
  end

  test "super_admin can manage teachers" do
    policy = TeacherPolicy.new(@admin, :teacher)
    assert policy.index?
    assert policy.assign_student?
  end

  test "teacher cannot manage other teachers" do
    policy = TeacherPolicy.new(@teacher, :teacher)
    refute policy.index?
    refute policy.assign_student?
  end

  test "student cannot manage teachers" do
    policy = TeacherPolicy.new(@student, :teacher)
    refute policy.index?
    refute policy.update?
  end
end
