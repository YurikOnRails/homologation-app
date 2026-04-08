require "test_helper"

class ChatsPolicyTest < ActiveSupport::TestCase
  setup do
    @coordinator = create(:user, :coordinator)
    @admin = create(:user, :super_admin)
    @student = create(:user, :student)
    @teacher = create(:user, :teacher)
  end

  test "coordinator cannot access chats" do
    policy = ChatsPolicy.new(@coordinator, :chats)
    refute policy.index?
    refute policy.show?
  end

  test "super_admin can access chats" do
    policy = ChatsPolicy.new(@admin, :chats)
    assert policy.index?
    assert policy.show?
  end

  test "student cannot access chats" do
    policy = ChatsPolicy.new(@student, :chats)
    refute policy.index?
    refute policy.show?
  end

  test "teacher cannot access chats" do
    refute ChatsPolicy.new(@teacher, :chats).index?
  end
end
