require "test_helper"

class HomologationRequestTest < ActiveSupport::TestCase
  test "valid transition from draft to submitted" do
    request = homologation_requests(:ana_draft)
    request.transition_to!("submitted", changed_by: users(:student_ana))
    assert_equal "submitted", request.reload.status
  end

  test "invalid transition from draft to resolved raises error" do
    request = homologation_requests(:ana_draft)
    assert_raises(HomologationRequest::InvalidTransition) do
      request.transition_to!("resolved", changed_by: users(:coordinator_maria))
    end
  end

  test "full happy path transition chain" do
    request = homologation_requests(:ana_draft)
    coordinator = users(:coordinator_maria)
    student = users(:student_ana)

    request.transition_to!("submitted", changed_by: student)
    request.transition_to!("in_review", changed_by: coordinator)
    request.transition_to!("awaiting_payment", changed_by: coordinator)
    request.transition_to!("payment_confirmed", changed_by: coordinator)
    request.transition_to!("in_progress", changed_by: coordinator)
    request.transition_to!("resolved", changed_by: coordinator)
    assert_equal "resolved", request.reload.status
  end

  test "payment_confirmed_at is set when transitioning to payment_confirmed" do
    request = homologation_requests(:ana_equivalencia)
    request.update_columns(status: "awaiting_payment")
    request.transition_to!("payment_confirmed", changed_by: users(:coordinator_maria))
    assert_not_nil request.payment_confirmed_at
  end

  test "subject is required" do
    request = HomologationRequest.new(user: users(:student_ana), service_type: "equivalencia")
    refute request.valid?
    assert request.errors[:subject].any?
  end

  test "service_type is required" do
    request = HomologationRequest.new(user: users(:student_ana), subject: "Test")
    refute request.valid?
    assert request.errors[:service_type].any?
  end

  test "soft delete discard and kept scopes" do
    request = homologation_requests(:ana_equivalencia)
    assert_includes HomologationRequest.kept, request
    request.discard
    refute_includes HomologationRequest.kept.reload, request
    assert_includes HomologationRequest.discarded, request
  end

  test "undiscard restores request" do
    request = homologation_requests(:ana_draft)
    request.discard
    request.undiscard
    assert_includes HomologationRequest.kept, request
    refute request.discarded?
  end

  test "transition to submitted creates a conversation" do
    request = homologation_requests(:ana_draft)
    assert_difference "Conversation.count", 1 do
      request.transition_to!("submitted", changed_by: users(:student_ana))
    end
    assert_not_nil request.reload.conversation
  end

  test "conversation participant created for student on submission" do
    request = homologation_requests(:ana_draft)
    assert_difference "ConversationParticipant.count", 1 do
      request.transition_to!("submitted", changed_by: users(:student_ana))
    end
  end
end
