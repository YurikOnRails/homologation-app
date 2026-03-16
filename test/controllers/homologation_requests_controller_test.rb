require "test_helper"

class HomologationRequestsControllerTest < ActionDispatch::IntegrationTest
  test "student sees own requests" do
    sign_in users(:student_ana)
    get homologation_requests_path
    assert_response :ok
    assert_equal "Requests/Index", inertia.component
  end

  test "coordinator sees all requests" do
    sign_in users(:coordinator_maria)
    get homologation_requests_path
    assert_response :ok
    assert_equal "Requests/Index", inertia.component
  end

  test "teacher cannot access requests" do
    sign_in users(:teacher_ivan)
    get homologation_requests_path
    assert_response :forbidden
  end

  test "student can view own request" do
    sign_in users(:student_ana)
    get homologation_request_path(homologation_requests(:ana_equivalencia))
    assert_response :ok
    assert_equal "Requests/Show", inertia.component
  end

  test "student cannot see other student request" do
    sign_in users(:student_pedro)
    get homologation_request_path(homologation_requests(:ana_equivalencia))
    assert_response :forbidden
  end

  test "coordinator can view any request" do
    sign_in users(:coordinator_maria)
    get homologation_request_path(homologation_requests(:ana_equivalencia))
    assert_response :ok
  end

  test "student can create request" do
    sign_in users(:student_ana)
    assert_difference "HomologationRequest.count", 1 do
      post homologation_requests_path, params: {
        subject: "New Request", service_type: "equivalencia",
        description: "Test", privacy_accepted: true
      }
    end
    assert_equal "submitted", HomologationRequest.last.status
  end

  test "student can save draft" do
    sign_in users(:student_ana)
    post homologation_requests_path, params: {
      commit: "draft",
      subject: "Draft", service_type: "equivalencia"
    }
    assert_equal "draft", HomologationRequest.last.status
  end

  test "coordinator can change status" do
    sign_in users(:coordinator_maria)
    request = homologation_requests(:ana_equivalencia)
    patch homologation_request_path(request), params: { status: "in_review" }
    assert_equal "in_review", request.reload.status
  end

  test "coordinator can confirm payment" do
    sign_in users(:coordinator_maria)
    request = homologation_requests(:ana_equivalencia)
    request.update!(status: "awaiting_payment")
    post confirm_payment_homologation_request_path(request), params: { payment_amount: 60 }
    assert_redirected_to homologation_request_path(request)
    assert_equal "payment_confirmed", request.reload.status
    assert_equal 60.0, request.reload.payment_amount.to_f
  end

  test "student cannot confirm payment" do
    sign_in users(:student_ana)
    request = homologation_requests(:ana_equivalencia)
    request.update!(status: "awaiting_payment")
    post confirm_payment_homologation_request_path(request), params: { payment_amount: 60 }
    assert_response :forbidden
  end

  test "student cannot update status" do
    sign_in users(:student_ana)
    request = homologation_requests(:ana_equivalencia)
    patch homologation_request_path(request), params: { status: "in_review" }
    assert_response :forbidden
  end

  test "student can access new request form" do
    sign_in users(:student_ana)
    get new_homologation_request_path
    assert_response :ok
    assert_equal "Requests/New", inertia.component
  end

  test "coordinator cannot create request (only students can)" do
    sign_in users(:coordinator_maria)
    assert_no_difference "HomologationRequest.count" do
      post homologation_requests_path, params: {
        subject: "Test", service_type: "equivalencia", privacy_accepted: true
      }
    end
    assert_response :forbidden
  end

  test "soft-deleted request is not accessible via show" do
    sign_in users(:student_ana)
    request = homologation_requests(:ana_equivalencia)
    request.discard

    get homologation_request_path(request)
    assert_response :not_found
  end

  test "submitted request auto-creates conversation" do
    sign_in users(:student_ana)
    assert_difference "Conversation.count", 1 do
      post homologation_requests_path, params: {
        subject: "With conversation", service_type: "equivalencia",
        privacy_accepted: true
      }
    end
    new_request = HomologationRequest.last
    assert_not_nil new_request.conversation
    assert_includes new_request.conversation.participants, users(:student_ana)
  end

  test "draft request does not create conversation" do
    sign_in users(:student_ana)
    assert_no_difference "Conversation.count" do
      post homologation_requests_path, params: {
        commit: "draft",
        subject: "Draft only", service_type: "equivalencia"
      }
    end
  end

  test "payment confirmation triggers AmoCRM sync job" do
    sign_in users(:coordinator_maria)
    request = homologation_requests(:ana_equivalencia)
    request.update!(status: "awaiting_payment")

    assert_enqueued_with(job: AmoCrmSyncJob) do
      post confirm_payment_homologation_request_path(request), params: { payment_amount: 150 }
    end
  end

  test "coordinator can retry AmoCRM sync" do
    sign_in users(:coordinator_maria)
    request = homologation_requests(:ana_equivalencia)
    request.update!(status: "payment_confirmed", amo_crm_sync_error: "API timeout")

    post retry_sync_homologation_request_path(request)
    assert_redirected_to homologation_request_path(request)
    assert_nil request.reload.amo_crm_sync_error
  end

  test "student cannot retry AmoCRM sync" do
    sign_in users(:student_ana)
    request = homologation_requests(:ana_equivalencia)
    request.update!(status: "payment_confirmed", amo_crm_sync_error: "API timeout")

    post retry_sync_homologation_request_path(request)
    assert_response :forbidden
  end

  test "coordinator is added as conversation participant on show" do
    sign_in users(:coordinator_maria)
    request = homologation_requests(:ana_equivalencia)
    conv = request.conversation

    get homologation_request_path(request)
    assert_includes conv.participants, users(:coordinator_maria)
  end
end
