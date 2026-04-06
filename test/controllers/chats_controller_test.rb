require "test_helper"

class ChatsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, :super_admin)
    @coordinator = create(:user, :coordinator)
    @student = create(:user, :student)
    @teacher = create(:user, :teacher)
    @request = create(:homologation_request, :submitted, :with_conversation, user: @student)
    @conversation = @request.conversation
  end

  test "coordinator cannot access chats" do
    sign_in @coordinator
    get chats_path
    assert_response :forbidden
  end

  test "super_admin can access chats" do
    sign_in @admin
    get chats_path
    assert_response :ok
    assert_equal "chats/Index", inertia.component
  end

  test "student cannot access chats" do
    sign_in @student
    get chats_path
    assert_response :forbidden
  end

  test "teacher cannot access chats" do
    sign_in @teacher
    get chats_path
    assert_response :forbidden
  end

  test "super_admin can view conversation in chats" do
    sign_in @admin
    get chat_path(@conversation)
    assert_response :ok
    assert_equal "chats/Index", inertia.component
  end

  test "chats index includes conversations list" do
    sign_in @admin
    get chats_path
    assert_response :ok
    props = inertia.props
    assert props[:conversations].is_a?(Array)
  end

  # === Unread mark-as-read ===

  test "show creates participant and marks as read when admin is not a participant" do
    sign_in @admin
    # Admin is NOT a participant yet
    assert_nil @conversation.conversation_participants.find_by(user: @admin)

    assert_difference "ConversationParticipant.count", 1 do
      get chat_path(@conversation)
    end

    assert_response :ok
    cp = @conversation.conversation_participants.find_by(user: @admin)
    assert_not_nil cp
    assert_not_nil cp.last_read_at
  end

  test "show marks as read without creating duplicate when admin is already a participant" do
    sign_in @admin
    @conversation.add_participant!(@admin)

    assert_no_difference "ConversationParticipant.count" do
      get chat_path(@conversation)
    end

    assert_response :ok
    cp = @conversation.conversation_participants.find_by(user: @admin)
    assert_not_nil cp.last_read_at
  end

  test "conversation shows unread false in list after admin opens it" do
    sign_in @admin
    # Add a message so conversation has last_message_at
    create(:message, conversation: @conversation, user: @student)
    @conversation.update!(last_message_at: Time.current)

    get chat_path(@conversation)
    assert_response :ok

    props = inertia.props
    opened = props[:conversations].find { |c| c[:id] == @conversation.id }
    assert_not opened[:unread], "Conversation should be marked as read after opening"
  end

  test "conversation shows unread true in list when admin has not opened it" do
    sign_in @admin
    # Add admin as participant with old last_read_at, then add a newer message
    cp = @conversation.add_participant!(@admin)
    cp.update_columns(last_read_at: 1.hour.ago)
    @conversation.update!(last_message_at: Time.current)

    get chats_path
    assert_response :ok

    props = inertia.props
    conv = props[:conversations].find { |c| c[:id] == @conversation.id }
    assert conv[:unread], "Conversation should be unread when last_read_at < last_message_at"
  end
end
