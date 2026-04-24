require "test_helper"

class HomologationRequestTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @student = create(:user, :student)
    @coordinator = create(:user, :coordinator)
    @draft_request = create(:homologation_request, :draft, user: @student)
    @submitted_request = create(:homologation_request, :submitted, :with_conversation, user: @student)
  end

  test "valid transition from draft to submitted" do
    @draft_request.update!(privacy_accepted: true)
    @draft_request.transition_to!("submitted", changed_by: @student)
    assert_equal "submitted", @draft_request.reload.status
  end

  test "invalid transition from draft to resolved raises error" do
    assert_raises(HomologationRequest::InvalidTransition) do
      @draft_request.transition_to!("resolved", changed_by: @coordinator)
    end
  end

  test "full happy path transition chain" do
    @draft_request.update!(privacy_accepted: true)
    @draft_request.transition_to!("submitted", changed_by: @student)
    @draft_request.transition_to!("in_review", changed_by: @coordinator)
    @draft_request.transition_to!("awaiting_payment", changed_by: @coordinator)
    @draft_request.update!(payment_amount: 100)
    @draft_request.transition_to!("payment_confirmed", changed_by: @coordinator)
    @draft_request.transition_to!("in_progress", changed_by: @coordinator)
    @draft_request.transition_to!("resolved", changed_by: @coordinator)
    assert_equal "resolved", @draft_request.reload.status
  end

  test "payment_confirmed_at is set when transitioning to payment_confirmed" do
    @submitted_request.update_columns(status: "awaiting_payment", payment_amount: 100)
    @submitted_request.transition_to!("payment_confirmed", changed_by: @coordinator)
    assert_not_nil @submitted_request.payment_confirmed_at
  end

  test "subject is required" do
    request = HomologationRequest.new(user: @student, service_type: "equivalencia")
    refute request.valid?
    assert request.errors[:subject].any?
  end

  test "service_type is required" do
    request = HomologationRequest.new(user: @student, subject: "Test")
    refute request.valid?
    assert request.errors[:service_type].any?
  end

  # === File validations ===

  test "accepts pdf in originals" do
    attach_blob(@draft_request.originals, "diploma.pdf", "application/pdf", "pdf")
    assert @draft_request.valid?, @draft_request.errors.full_messages.join(", ")
  end

  test "accepts jpeg in originals" do
    attach_blob(@draft_request.originals, "scan.jpg", "image/jpeg", "jpeg")
    assert @draft_request.valid?
  end

  test "accepts png in documents" do
    attach_blob(@draft_request.documents, "page.png", "image/png", "png")
    assert @draft_request.valid?
  end

  test "accepts webp in application" do
    attach_blob(@draft_request.application, "form.webp", "image/webp", "webp")
    assert @draft_request.valid?
  end

  test "rejects executable in originals" do
    attach_blob(@draft_request.originals, "malware.exe", "application/x-msdownload", "exe")
    refute @draft_request.valid?
    assert @draft_request.errors[:originals].any?, "expected :originals error, got #{@draft_request.errors.full_messages}"
  end

  test "rejects gif in documents" do
    attach_blob(@draft_request.documents, "animation.gif", "image/gif", "gif")
    refute @draft_request.valid?
    assert @draft_request.errors[:documents].any?
  end

  test "rejects disallowed content type in application" do
    attach_blob(@draft_request.application, "form.zip", "application/zip", "zip")
    refute @draft_request.valid?
    assert @draft_request.errors[:application].any?
  end

  test "rejects oversized file in originals" do
    @draft_request.originals.attach(
      io: StringIO.new("A" * 16.megabytes),
      filename: "huge.pdf",
      content_type: "application/pdf"
    )
    refute @draft_request.valid?
    assert @draft_request.errors[:originals].any?
  end

  test "rejects oversized file in application" do
    @draft_request.application.attach(
      io: StringIO.new("A" * 16.megabytes),
      filename: "huge.pdf",
      content_type: "application/pdf"
    )
    refute @draft_request.valid?
    assert @draft_request.errors[:application].any?
  end

  test "soft delete discard and kept scopes" do
    assert_includes HomologationRequest.kept, @submitted_request
    @submitted_request.discard
    refute_includes HomologationRequest.kept.reload, @submitted_request
    assert_includes HomologationRequest.discarded, @submitted_request
  end

  test "undiscard restores request" do
    @draft_request.discard
    @draft_request.undiscard
    assert_includes HomologationRequest.kept, @draft_request
    refute @draft_request.discarded?
  end

  test "transition to submitted creates a conversation" do
    @draft_request.update!(privacy_accepted: true)
    assert_difference "Conversation.count", 1 do
      @draft_request.transition_to!("submitted", changed_by: @student)
    end
    assert_not_nil @draft_request.reload.conversation
  end

  test "conversation participant created for student on submission" do
    @draft_request.update!(privacy_accepted: true)
    assert_difference "ConversationParticipant.count", 1 do
      @draft_request.transition_to!("submitted", changed_by: @student)
    end
  end

  # === Status machine: invalid transitions blocked ===

  test "cannot skip from submitted directly to payment_confirmed" do
    assert_raises(HomologationRequest::InvalidTransition) do
      @submitted_request.transition_to!("payment_confirmed", changed_by: @coordinator)
    end
  end

  test "cannot go backwards from in_review to submitted" do
    @submitted_request.update_columns(status: "in_review")
    assert_raises(HomologationRequest::InvalidTransition) do
      @submitted_request.transition_to!("submitted", changed_by: @coordinator)
    end
  end

  test "awaiting_reply can return to in_review" do
    @submitted_request.update_columns(status: "awaiting_reply")
    @submitted_request.transition_to!("in_review", changed_by: @coordinator)
    assert_equal "in_review", @submitted_request.status
  end

  test "in_progress can transition to closed" do
    @submitted_request.update_columns(status: "in_progress")
    @submitted_request.transition_to!("closed", changed_by: @coordinator)
    assert_equal "closed", @submitted_request.status
  end

  test "resolved is a terminal state" do
    @submitted_request.update_columns(status: "resolved")
    assert_raises(HomologationRequest::InvalidTransition) do
      @submitted_request.transition_to!("in_progress", changed_by: @coordinator)
    end
  end

  test "transition sets status_changed_by" do
    @submitted_request.transition_to!("in_review", changed_by: @coordinator)
    assert_equal @coordinator.id, @submitted_request.status_changed_by
  end

  test "transition sets status_changed_at" do
    @submitted_request.transition_to!("in_review", changed_by: @coordinator)
    assert_not_nil @submitted_request.status_changed_at
  end

  test "post-payment status transition enqueues AmoCrmStatusSyncJob" do
    @submitted_request.update_columns(status: "payment_confirmed", amo_crm_lead_id: "888")

    assert_enqueued_with(job: AmoCrmStatusSyncJob) do
      @submitted_request.transition_to!("in_progress", changed_by: @coordinator)
    end
  end

  test "pre-payment status transition does not enqueue AmoCrmStatusSyncJob" do
    assert_no_enqueued_jobs(only: AmoCrmStatusSyncJob) do
      @submitted_request.transition_to!("in_review", changed_by: @coordinator)
    end
  end

  # === Privacy accepted validation ===

  test "submitted request requires privacy_accepted" do
    request = HomologationRequest.new(
      user: @student, subject: "Test", service_type: "equivalencia",
      status: "submitted", privacy_accepted: false
    )
    refute request.valid?
    assert request.errors[:privacy_accepted].any?
  end

  test "draft request does not require privacy_accepted" do
    request = HomologationRequest.new(
      user: @student, subject: "Test", service_type: "equivalencia",
      status: "draft", privacy_accepted: false
    )
    assert request.valid?, "Expected draft to be valid without privacy_accepted: #{request.errors.full_messages}"
  end

  test "submitted request with privacy_accepted true is valid" do
    request = HomologationRequest.new(
      user: @student, subject: "Test", service_type: "equivalencia",
      status: "submitted", privacy_accepted: true
    )
    assert request.valid?, "Expected submitted request with privacy_accepted to be valid: #{request.errors.full_messages}"
  end

  # NOTE: Pipeline tests (enter_pipeline!, advance_pipeline!, retreat_pipeline!,
  # toggle_checklist_item!, sync_status_from_pipeline!) live in test/models/pipeline_test.rb

  private

  def attach_blob(attachable, filename, content_type, ext)
    attachable.attach(
      io: StringIO.new("stub-#{ext}-bytes"),
      filename: filename,
      content_type: content_type
    )
  end
end
