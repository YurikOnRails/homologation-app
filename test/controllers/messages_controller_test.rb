require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = create(:user, :student)
    @other_student = create(:user, :student)
    @coordinator = create(:user, :coordinator)
    @admin = create(:user, :super_admin)
    @teacher = create(:user, :teacher)

    @hr = create(:homologation_request, :submitted, :with_conversation, user: @student)
    @conversation = @hr.conversation

    @teacher_student = create(:teacher_student, teacher: @teacher, student: @student, assigned_by: @coordinator.id)
    @teacher_conversation = Conversation.create!(teacher_student_id: @teacher_student.id)
    @teacher_conversation.conversation_participants.create!(user: @teacher)
    @teacher_conversation.conversation_participants.create!(user: @student)
  end

  test "student can send message in own request conversation" do
    sign_in @student
    assert_difference "Message.count", 1 do
      post homologation_request_messages_path(@hr),
           params: { body: "Hello coordinator" }
    end
  end

  test "coordinator cannot send message in request conversation" do
    sign_in @coordinator
    assert_no_difference "Message.count" do
      post homologation_request_messages_path(@hr),
           params: { body: "I'll review your documents" }
    end
    assert_response :forbidden
  end

  test "super_admin can send message in any request conversation" do
    sign_in @admin
    assert_difference "Message.count", 1 do
      post homologation_request_messages_path(@hr),
           params: { body: "I'll review your documents" }
    end
  end

  test "unauthorized student cannot send message in other's request" do
    sign_in @other_student
    assert_no_difference "Message.count" do
      post homologation_request_messages_path(@hr),
           params: { body: "Hacking attempt" }
    end
    assert_response :forbidden
  end

  test "empty body does not create message" do
    sign_in @student
    assert_no_difference "Message.count" do
      post homologation_request_messages_path(@hr),
           params: { body: "" }
    end
  end

  test "teacher can send message in teacher-student conversation" do
    sign_in @teacher
    assert_difference "Message.count", 1 do
      post conversation_messages_path(@teacher_conversation),
           params: { body: "Ready for our lesson?" }
    end
  end

  test "student can send message in teacher-student conversation" do
    sign_in @student
    assert_difference "Message.count", 1 do
      post conversation_messages_path(@teacher_conversation),
           params: { body: "Yes, I'm ready!" }
    end
  end

  test "unrelated student cannot send message in teacher-student conversation" do
    sign_in @other_student
    assert_no_difference "Message.count" do
      post conversation_messages_path(@teacher_conversation),
           params: { body: "Not my conversation" }
    end
    assert_response :forbidden
  end
end
