require "test_helper"
require "webmock/minitest"

class AmoCrmStatusSyncJobTest < ActiveJob::TestCase
  setup do
    WebMock.disable_net_connect!

    AmoCrmToken.create!(
      access_token: "test_token",
      refresh_token: "test_refresh",
      expires_at: 1.hour.from_now
    )

    stub_request(:patch, /api\/v4\/leads/)
      .to_return(status: 200, body: "{}",
                 headers: { "Content-Type" => "application/json" })
  end

  teardown do
    WebMock.allow_net_connect!
    WebMock.reset!
  end

  test "updates lead status in AmoCRM" do
    request = homologation_requests(:ana_equivalencia)
    request.update!(amo_crm_lead_id: "888", status: "in_progress")

    AmoCrmStatusSyncJob.perform_now(request.id)

    assert_requested :patch, /api\/v4\/leads\/888/
  end

  test "skips when no amo_crm_lead_id" do
    request = homologation_requests(:ana_equivalencia)
    request.update!(amo_crm_lead_id: nil, status: "in_progress")

    AmoCrmStatusSyncJob.perform_now(request.id)

    assert_not_requested :patch, /api\/v4\/leads/
  end
end
