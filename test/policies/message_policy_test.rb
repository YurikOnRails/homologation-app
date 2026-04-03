require "test_helper"

class MessagePolicyTest < ActiveSupport::TestCase
  setup do
    @ana = create(:user, :student)
    @pedro = create(:user, :student)
    @maria = create(:user, :coordinator)
    @boss = create(:user, :super_admin)
    @ivan = create(:user, :teacher)

    # Request conversation: ana is participant, maria is participant
    @submitted_request = create(:homologation_request, :submitted, :with_conversation, user: @ana)
    @request_conversation = @submitted_request.conversation
    @request_conversation.conversation_participants.create!(user: @maria)

    # Teacher-student conversation
    @teacher_student = create(:teacher_student, teacher: @ivan, student: @ana, assigned_by: @maria.id)
    @teacher_conversation = Conversation.create!(teacher_student_id: @teacher_student.id)
    @teacher_conversation.conversation_participants.create!(user: @ivan)
    @teacher_conversation.conversation_participants.create!(user: @ana)
  end

  # === Request conversations ===

  test "student can send message in own request conversation" do
    msg = @request_conversation.messages.build(user: @ana, body: "test")
    assert MessagePolicy.new(@ana, msg).create?
  end

  test "student cannot send message in another student's request conversation" do
    msg = @request_conversation.messages.build(user: @pedro, body: "test")
    refute MessagePolicy.new(@pedro, msg).create?
  end

  test "coordinator cannot send message in request conversation" do
    msg = @request_conversation.messages.build(user: @maria, body: "test")
    refute MessagePolicy.new(@maria, msg).create?
  end

  test "super_admin can send message in any request conversation" do
    msg = @request_conversation.messages.build(user: @boss, body: "test")
    assert MessagePolicy.new(@boss, msg).create?
  end

  # === Teacher-student conversations ===

  test "teacher can send message to assigned student" do
    msg = @teacher_conversation.messages.build(user: @ivan, body: "test")
    assert MessagePolicy.new(@ivan, msg).create?
  end

  test "assigned student can send message to teacher" do
    msg = @teacher_conversation.messages.build(user: @ana, body: "test")
    assert MessagePolicy.new(@ana, msg).create?
  end

  test "unrelated student cannot send message in teacher-student conversation" do
    msg = @teacher_conversation.messages.build(user: @pedro, body: "test")
    refute MessagePolicy.new(@pedro, msg).create?
  end

  test "coordinator can send message in teacher-student conversation" do
    msg = @teacher_conversation.messages.build(user: @maria, body: "test")
    assert MessagePolicy.new(@maria, msg).create?
  end
end
