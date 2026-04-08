require "test_helper"

class ConversationTest < ActiveSupport::TestCase
  setup do
    @student = create(:user, :student)
    @teacher = create(:user, :teacher)
    @request = create(:homologation_request, :submitted, :with_conversation, user: @student)
    @conversation = @request.conversation
  end

  test "must have either homologation_request or teacher_student" do
    conversation = Conversation.new
    refute conversation.valid?
    assert conversation.errors[:base].any?
  end

  test "valid with homologation_request" do
    assert @conversation.valid?
  end

  test "add_participant! adds user to conversation" do
    assert_difference "ConversationParticipant.count", 1 do
      @conversation.add_participant!(@teacher)
    end
  end

  test "add_participant! is idempotent" do
    assert_no_difference "ConversationParticipant.count" do
      @conversation.add_participant!(@student) # already a participant
    end
  end
end
