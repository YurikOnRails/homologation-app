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
end
