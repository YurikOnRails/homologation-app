require "test_helper"

class ConversationTest < ActiveSupport::TestCase
  test "must have either homologation_request or teacher_student" do
    conversation = Conversation.new
    refute conversation.valid?
    assert conversation.errors[:base].any?
  end

  test "valid with homologation_request" do
    assert conversations(:ana_equivalencia_conversation).valid?
  end

  test "add_participant! adds user to conversation" do
    conversation = conversations(:ana_equivalencia_conversation)
    teacher = users(:teacher_ivan)
    assert_difference "ConversationParticipant.count", 1 do
      conversation.add_participant!(teacher)
    end
  end

  test "add_participant! is idempotent" do
    conversation = conversations(:ana_equivalencia_conversation)
    student = users(:student_ana)  # already a participant
    assert_no_difference "ConversationParticipant.count" do
      conversation.add_participant!(student)
    end
  end
end
