require "test_helper"

class ConversationPolicyTest < ActiveSupport::TestCase
  setup do
    @ana = create(:user, :student)
    @pedro = create(:user, :student)
    @maria = create(:user, :coordinator)
    @ivan = create(:user, :teacher)
    @boss = create(:user, :super_admin)

    # Request conversation: ana + maria as participants
    @submitted_request = create(:homologation_request, :submitted, :with_conversation, user: @ana)
    @request_conv = @submitted_request.conversation
    @request_conv.conversation_participants.create!(user: @maria)

    # Teacher-student conversation: ivan + ana as participants
    @teacher_student = create(:teacher_student, teacher: @ivan, student: @ana, assigned_by: @maria.id)
    @teacher_conv = Conversation.create!(teacher_student_id: @teacher_student.id)
    @teacher_conv.conversation_participants.create!(user: @ivan)
    @teacher_conv.conversation_participants.create!(user: @ana)
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
    assert ConversationPolicy.new(@maria, @request_conv).show?
  end

  test "coordinator cannot view conversation they do not participate in" do
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
