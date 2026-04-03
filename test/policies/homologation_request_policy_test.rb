require "test_helper"

class HomologationRequestPolicyTest < ActiveSupport::TestCase
  setup do
    @ana = create(:user, :student)
    @pedro = create(:user, :student)
    @maria = create(:user, :coordinator)
    @boss = create(:user, :super_admin)
    @ivan = create(:user, :teacher)
    @ana_request = create(:homologation_request, :submitted, user: @ana)
  end

  # === index? ===

  test "student can list requests" do
    assert HomologationRequestPolicy.new(@ana, HomologationRequest).index?
  end

  test "coordinator cannot list requests" do
    refute HomologationRequestPolicy.new(@maria, HomologationRequest).index?
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

  test "coordinator cannot see requests" do
    refute HomologationRequestPolicy.new(@maria, @ana_request).show?
  end

  test "super_admin can see any request" do
    assert HomologationRequestPolicy.new(@boss, @ana_request).show?
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

  test "super_admin can update request" do
    assert HomologationRequestPolicy.new(@boss, @ana_request).update?
  end

  test "coordinator cannot update request" do
    refute HomologationRequestPolicy.new(@maria, @ana_request).update?
  end

  test "student cannot update request (only super_admin manages status)" do
    refute HomologationRequestPolicy.new(@ana, @ana_request).update?
  end

  # === confirm_payment? ===

  test "super_admin can confirm payment when status is awaiting_payment" do
    @ana_request.status = "awaiting_payment"
    assert HomologationRequestPolicy.new(@boss, @ana_request).confirm_payment?
  end

  test "super_admin cannot confirm payment when status is not awaiting_payment" do
    @ana_request.status = "in_review"
    refute HomologationRequestPolicy.new(@boss, @ana_request).confirm_payment?
  end

  test "coordinator cannot confirm payment" do
    @ana_request.status = "awaiting_payment"
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

  test "coordinator cannot download documents" do
    refute HomologationRequestPolicy.new(@maria, @ana_request).download_document?
  end

  test "super_admin can download any document" do
    assert HomologationRequestPolicy.new(@boss, @ana_request).download_document?
  end

  # === Scope ===

  test "student scope returns only own kept requests" do
    scope = HomologationRequestPolicy::Scope.new(@ana, HomologationRequest).resolve
    assert scope.all? { |r| r.user_id == @ana.id }
    assert scope.all? { |r| r.discarded_at.nil? }
  end

  test "coordinator scope returns nothing" do
    scope = HomologationRequestPolicy::Scope.new(@maria, HomologationRequest).resolve
    assert_empty scope
  end

  test "super_admin scope returns all kept requests" do
    scope = HomologationRequestPolicy::Scope.new(@boss, HomologationRequest).resolve
    assert_includes scope, @ana_request
  end

  test "teacher scope returns nothing" do
    scope = HomologationRequestPolicy::Scope.new(@ivan, HomologationRequest).resolve
    assert_empty scope
  end

  test "scope excludes soft-deleted requests" do
    @ana_request.discard
    scope = HomologationRequestPolicy::Scope.new(@boss, HomologationRequest).resolve
    refute_includes scope, @ana_request
  end
end
