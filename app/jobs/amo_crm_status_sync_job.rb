class AmoCrmStatusSyncJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  # Maps app status → AmoCRM pipeline stage ID
  STATUS_MAP = {
    "payment_confirmed" => :new_status_id,
    "in_progress"       => :in_progress_status_id,
    "resolved"          => :won_status_id,
    "closed"            => :lost_status_id
  }.freeze

  def perform(request_id)
    request = HomologationRequest.find(request_id)
    return unless request.amo_crm_lead_id.present?

    status_key = STATUS_MAP[request.status]
    return unless status_key

    status_id = Rails.application.credentials.dig(:amo_crm, status_key) || 0
    client = AmoCrmClient.new
    client.update_lead_status(request.amo_crm_lead_id.to_i, status_id)
  end
end
