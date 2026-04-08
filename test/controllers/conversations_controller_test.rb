require "test_helper"

class ConversationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = create(:user, :student)
    @other_student = create(:user, :student)
    @coordinator = create(:user, :coordinator)
    @teacher = create(:user, :teacher)
    @request = create(:homologation_request, :submitted, :with_conversation, user: @student)
    @conversation = @request.conversation
    @conversation.conversation_participants.create!(user: @coordinator)
    @participant = @conversation.conversation_participants.find_by(user: @student)
  end

  test "student sees own conversations" do
    sign_in @student
    get conversations_path
    assert_response :ok
    assert_equal "chat/Index", inertia.component
  end

  test "teacher sees own conversations" do
    sign_in @teacher
    get conversations_path
    assert_response :ok
    assert_equal "chat/Index", inertia.component
  end

  test "student can view own conversation" do
    sign_in @student
    get conversation_path(@conversation)
    assert_response :ok
    assert_equal "chat/Show", inertia.component
  end

  test "student cannot view unrelated conversation" do
    sign_in @other_student
    get conversation_path(@conversation)
    assert_response :forbidden
  end

  test "coordinator can view any conversation" do
    sign_in @coordinator
    get conversation_path(@conversation)
    assert_response :ok
  end

  test "show marks conversation as read" do
    sign_in @student
    assert_nil @participant.last_read_at

    get conversation_path(@conversation)
    assert_not_nil @participant.reload.last_read_at
  end
end
