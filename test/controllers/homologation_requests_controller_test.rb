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
end
