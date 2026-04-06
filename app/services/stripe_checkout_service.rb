class StripeCheckoutService
  class Error < StandardError; end

  def initialize(request, created_by:)
    @request = request
    @created_by = created_by
  end

  def create_session(amount:)
    customer = find_or_create_customer
    session = Stripe::Checkout::Session.create(
      customer: customer.id,
      mode: "payment",
      line_items: [ {
        price_data: {
          currency: "eur",
          unit_amount: (amount * 100).to_i,
          product_data: {
            name: I18n.t("stripe.product_name", subject: @request.subject)
          }
        },
        quantity: 1
      } ],
      metadata: {
        homologation_request_id: @request.id,
        amount: amount.to_s,
        created_by: @created_by.id
      },
      success_url: success_url,
      cancel_url: cancel_url
    )

    session
  rescue Stripe::StripeError => e
    raise Error, e.message
  end

  private

  def find_or_create_customer
    student = @request.user

    if student.stripe_customer_id.present?
      Stripe::Customer.retrieve(student.stripe_customer_id)
    else
      customer = Stripe::Customer.create(
        email: student.email_address,
        name: student.name,
        metadata: { user_id: student.id }
      )
      student.update!(stripe_customer_id: customer.id)
      customer
    end
  end

  def success_url
    "#{base_url}/requests/#{@request.id}?payment=success"
  end

  def cancel_url
    "#{base_url}/requests/#{@request.id}?payment=cancelled"
  end

  def base_url
    Rails.application.credentials.dig(:stripe, :base_url) || "http://localhost:3100"
  end
end
