require "test_helper"

class ConversationPolicyTest < ActiveSupport::TestCase
  setup do
    @ana = users(:student_ana)
    @pedro = users(:student_pedro)
    @maria = users(:coordinator_maria)
    @ivan = users(:teacher_ivan)
    @boss = users(:super_admin_boss)
    @request_conv = conversations(:ana_equivalencia_conversation)
    @teacher_conv = conversations(:ivan_ana_conversation)
  end

  test "any authenticated user can list conversations" do
    assert ConversationPolicy.new(@ana, :conversation).index?
    assert ConversationPolicy.new(@ivan, :conversation).index?
  end

  test "participant can view conversation" do
    assert ConversationPolicy.new(@ana, @request_conv).show?
  end

  test "non-participant student cannot view conversation" do
    refute ConversationPolicy.new(@pedro, @request_conv).show?
  end

  test "coordinator can view conversation they participate in" do
    # Maria is a participant in the request conversation (via fixture)
    assert ConversationPolicy.new(@maria, @request_conv).show?
  end

  test "coordinator cannot view conversation they do not participate in" do
    # Maria is NOT a participant in the teacher-student conversation
    refute ConversationPolicy.new(@maria, @teacher_conv).show?
  end

  test "super_admin can view any conversation" do
    assert ConversationPolicy.new(@boss, @teacher_conv).show?
    assert ConversationPolicy.new(@boss, @request_conv).show?
  end

  test "scope returns only conversations user participates in" do
    scope = ConversationPolicy::Scope.new(@pedro, Conversation).resolve
    assert_empty scope

    ana_scope = ConversationPolicy::Scope.new(@ana, Conversation).resolve
    assert_includes ana_scope, @request_conv
    assert_includes ana_scope, @teacher_conv
  end
end
