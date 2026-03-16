require "test_helper"
require "webmock/minitest"

class AmoCrmClientTest < ActiveSupport::TestCase
  setup do
    WebMock.disable_net_connect!

    # Create a token for the client to use
    AmoCrmToken.create!(
      access_token: "test_access_token",
      refresh_token: "test_refresh_token",
      expires_at: 1.hour.from_now
    )
  end

  teardown do
    WebMock.allow_net_connect!
    WebMock.reset!
  end

  test "find_or_create_contact creates new contact when none exists" do
    stub_request(:get, /api\/v4\/contacts/)
      .to_return(status: 200, body: { _embedded: { contacts: [] } }.to_json,
                 headers: { "Content-Type" => "application/json" })

    stub_request(:post, /api\/v4\/contacts/)
      .to_return(status: 200,
                 body: { _embedded: { contacts: [{ id: 999 }] } }.to_json,
                 headers: { "Content-Type" => "application/json" })

    client = AmoCrmClient.new
    contact_id = client.find_or_create_contact(users(:student_ana))
    assert_equal 999, contact_id
  end

  test "find_or_create_contact updates existing contact" do
    stub_request(:get, /api\/v4\/contacts/)
      .to_return(status: 200,
                 body: { _embedded: { contacts: [{ id: 777 }] } }.to_json,
                 headers: { "Content-Type" => "application/json" })

    stub_request(:patch, /api\/v4\/contacts\/777/)
      .to_return(status: 200, body: "{}",
                 headers: { "Content-Type" => "application/json" })

    client = AmoCrmClient.new
    contact_id = client.find_or_create_contact(users(:student_ana))
    assert_equal 777, contact_id
  end

  test "create_lead sends correct payload and returns lead id" do
    stub_request(:post, /api\/v4\/leads/)
      .to_return(status: 200,
                 body: { _embedded: { leads: [{ id: 888 }] } }.to_json,
                 headers: { "Content-Type" => "application/json" })

    client = AmoCrmClient.new
    lead_id = client.create_lead(homologation_requests(:ana_equivalencia), 999)
    assert_equal 888, lead_id
  end

  test "update_lead_status sends patch request" do
    stub_request(:patch, /api\/v4\/leads\/888/)
      .to_return(status: 200, body: "{}",
                 headers: { "Content-Type" => "application/json" })

    client = AmoCrmClient.new
    assert_nothing_raised do
      client.update_lead_status(888, 12345)
    end
  end

  test "raises on API error" do
    stub_request(:get, /api\/v4\/contacts/)
      .to_return(status: 500, body: "Internal Server Error")

    client = AmoCrmClient.new
    assert_raises(AmoCrmClient::ApiError) do
      client.find_or_create_contact(users(:student_ana))
    end
  end

  test "refreshes expired token" do
    AmoCrmToken.last.update!(expires_at: 1.minute.ago)

    stub_request(:post, /oauth2\/access_token/)
      .to_return(status: 200,
                 body: { access_token: "new_token", refresh_token: "new_refresh", expires_in: 86400 }.to_json,
                 headers: { "Content-Type" => "application/json" })

    stub_request(:get, /api\/v4\/contacts/)
      .to_return(status: 200, body: { _embedded: { contacts: [] } }.to_json,
                 headers: { "Content-Type" => "application/json" })

    stub_request(:post, /api\/v4\/contacts/)
      .to_return(status: 200,
                 body: { _embedded: { contacts: [{ id: 111 }] } }.to_json,
                 headers: { "Content-Type" => "application/json" })

    client = AmoCrmClient.new
    contact_id = client.find_or_create_contact(users(:student_ana))
    assert_equal 111, contact_id
    assert_equal "new_token", AmoCrmToken.last.access_token
  end
end
