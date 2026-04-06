require "test_helper"
require "ostruct"

class StripeWebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, :super_admin)
    @student = create(:user, :student)
    @request_record = create(:homologation_request, :submitted, user: @student)
    @request_record.update!(status: "awaiting_payment")
  end

  test "checkout.session.completed confirms payment and enters pipeline" do
    session_data = stripe_session_data(
      request_id: @request_record.id,
      amount: "150.00",
      created_by: @admin.id,
      payment_intent: "pi_test_123"
    )

    stub_webhook_construct(session_data) do
      assert_enqueued_with(job: AmoCrmSyncJob) do
        post "/webhooks/stripe", params: "{}", headers: { "HTTP_STRIPE_SIGNATURE" => "sig_test" }
      end
    end

    assert_response :ok
    @request_record.reload
    assert_equal "payment_confirmed", @request_record.status
    assert_equal 150.0, @request_record.payment_amount.to_f
    assert_equal "pi_test_123", @request_record.stripe_payment_intent_id
    assert_equal @admin.id, @request_record.payment_confirmed_by
    assert_not_nil @request_record.payment_confirmed_at
    assert_equal "pago_recibido", @request_record.pipeline_stage
  end

  test "ignores already confirmed requests" do
    @request_record.update!(
      status: "payment_confirmed",
      payment_amount: 100,
      payment_confirmed_by: @admin.id,
      payment_confirmed_at: Time.current
    )
    @request_record.enter_pipeline!

    session_data = stripe_session_data(
      request_id: @request_record.id,
      amount: "200.00",
      created_by: @admin.id,
      payment_intent: "pi_test_456"
    )

    stub_webhook_construct(session_data) do
      post "/webhooks/stripe", params: "{}", headers: { "HTTP_STRIPE_SIGNATURE" => "sig_test" }
    end

    assert_response :ok
    assert_equal 100.0, @request_record.reload.payment_amount.to_f
  end

  test "invalid signature returns bad request" do
    # Send request without stubbing — Stripe.api_key is nil in test, so construct_event will fail
    post "/webhooks/stripe",
      params: "{}",
      headers: { "HTTP_STRIPE_SIGNATURE" => "bad_sig", "CONTENT_TYPE" => "application/json" }

    assert_response :bad_request
  end

  test "enqueues notifications for student and admin" do
    session_data = stripe_session_data(
      request_id: @request_record.id,
      amount: "150.00",
      created_by: @admin.id,
      payment_intent: "pi_test_notif"
    )

    stub_webhook_construct(session_data) do
      assert_enqueued_jobs 2, only: NotificationJob do
        post "/webhooks/stripe", params: "{}", headers: { "HTTP_STRIPE_SIGNATURE" => "sig_test" }
      end
    end

    assert_response :ok
  end

  test "ignores nonexistent request id" do
    session_data = stripe_session_data(
      request_id: 999_999,
      amount: "100.00",
      created_by: @admin.id,
      payment_intent: "pi_test_missing"
    )

    stub_webhook_construct(session_data) do
      post "/webhooks/stripe", params: "{}", headers: { "HTTP_STRIPE_SIGNATURE" => "sig_test" }
    end

    assert_response :ok
  end

  test "ignores nonexistent confirmer" do
    session_data = stripe_session_data(
      request_id: @request_record.id,
      amount: "100.00",
      created_by: 999_999,
      payment_intent: "pi_test_no_confirmer"
    )

    stub_webhook_construct(session_data) do
      post "/webhooks/stripe", params: "{}", headers: { "HTTP_STRIPE_SIGNATURE" => "sig_test" }
    end

    assert_response :ok
    assert_equal "awaiting_payment", @request_record.reload.status
  end

  test "ignores unknown event types" do
    event = OpenStruct.new(type: "invoice.paid", data: OpenStruct.new(object: {}))
    original = Stripe::Webhook.method(:construct_event)
    Stripe::Webhook.define_singleton_method(:construct_event) { |*_args| event }

    post "/webhooks/stripe", params: "{}", headers: { "HTTP_STRIPE_SIGNATURE" => "sig_test" }
    assert_response :ok
  ensure
    Stripe::Webhook.define_singleton_method(:construct_event, original)
  end

  private

  def stripe_session_data(request_id:, amount:, created_by:, payment_intent:)
    {
      "metadata" => {
        "homologation_request_id" => request_id.to_s,
        "amount" => amount,
        "created_by" => created_by.to_s
      },
      "payment_intent" => payment_intent
    }
  end

  def stub_webhook_construct(session_data, &block)
    session = Stripe::Checkout::Session.construct_from(session_data)
    event = OpenStruct.new(
      type: "checkout.session.completed",
      data: OpenStruct.new(object: session)
    )

    original = Stripe::Webhook.method(:construct_event)
    Stripe::Webhook.define_singleton_method(:construct_event) { |*_args| event }
    yield
  ensure
    Stripe::Webhook.define_singleton_method(:construct_event, original)
  end
end
