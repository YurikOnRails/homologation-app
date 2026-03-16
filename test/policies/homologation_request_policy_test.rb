require "test_helper"

class HomologationRequestPolicyTest < ActiveSupport::TestCase
  setup do
    @ana = users(:student_ana)
    @pedro = users(:student_pedro)
    @maria = users(:coordinator_maria)
    @boss = users(:super_admin_boss)
    @ivan = users(:teacher_ivan)
    @ana_request = homologation_requests(:ana_equivalencia)
  end

  # === index? ===

  test "student can list requests" do
    assert HomologationRequestPolicy.new(@ana, HomologationRequest).index?
  end

  test "coordinator can list requests" do
    assert HomologationRequestPolicy.new(@maria, HomologationRequest).index?
  end

  test "super_admin can list requests" do
    assert HomologationRequestPolicy.new(@boss, HomologationRequest).index?
  end

  test "teacher cannot list requests" do
    refute HomologationRequestPolicy.new(@ivan, HomologationRequest).index?
  end

  # === show? ===

  test "student can see own request" do
    assert HomologationRequestPolicy.new(@ana, @ana_request).show?
  end

  test "student cannot see another student's request" do
    refute HomologationRequestPolicy.new(@pedro, @ana_request).show?
  end

  test "coordinator can see any request" do
    assert HomologationRequestPolicy.new(@maria, @ana_request).show?
  end

  test "teacher cannot see requests" do
    refute HomologationRequestPolicy.new(@ivan, @ana_request).show?
  end

  # === create? ===

  test "student can create request" do
    assert HomologationRequestPolicy.new(@ana, HomologationRequest.new).create?
  end

  test "coordinator cannot create request" do
    refute HomologationRequestPolicy.new(@maria, HomologationRequest.new).create?
  end

  test "teacher cannot create request" do
    refute HomologationRequestPolicy.new(@ivan, HomologationRequest.new).create?
  end

  # === update? ===

  test "coordinator can update request" do
    assert HomologationRequestPolicy.new(@maria, @ana_request).update?
  end

  test "student cannot update request (only coordinators manage status)" do
    refute HomologationRequestPolicy.new(@ana, @ana_request).update?
  end

  # === confirm_payment? ===

  test "coordinator can confirm payment when status is awaiting_payment" do
    @ana_request.status = "awaiting_payment"
    assert HomologationRequestPolicy.new(@maria, @ana_request).confirm_payment?
  end

  test "coordinator cannot confirm payment when status is not awaiting_payment" do
    @ana_request.status = "in_review"
    refute HomologationRequestPolicy.new(@maria, @ana_request).confirm_payment?
  end

  test "student cannot confirm payment even when awaiting_payment" do
    @ana_request.status = "awaiting_payment"
    refute HomologationRequestPolicy.new(@ana, @ana_request).confirm_payment?
  end

  # === download_document? ===

  test "student can download own document" do
    assert HomologationRequestPolicy.new(@ana, @ana_request).download_document?
  end

  test "student cannot download another student's document" do
    refute HomologationRequestPolicy.new(@pedro, @ana_request).download_document?
  end

  test "coordinator can download any document" do
    assert HomologationRequestPolicy.new(@maria, @ana_request).download_document?
  end

  # === Scope ===

  test "student scope returns only own kept requests" do
    scope = HomologationRequestPolicy::Scope.new(@ana, HomologationRequest).resolve
    assert scope.all? { |r| r.user_id == @ana.id }
    assert scope.all? { |r| r.discarded_at.nil? }
  end

  test "coordinator scope returns all kept requests" do
    scope = HomologationRequestPolicy::Scope.new(@maria, HomologationRequest).resolve
    assert_includes scope, @ana_request
  end

  test "teacher scope returns nothing" do
    scope = HomologationRequestPolicy::Scope.new(@ivan, HomologationRequest).resolve
    assert_empty scope
  end

  test "scope excludes soft-deleted requests" do
    @ana_request.discard
    scope = HomologationRequestPolicy::Scope.new(@maria, HomologationRequest).resolve
    refute_includes scope, @ana_request
  end
end
