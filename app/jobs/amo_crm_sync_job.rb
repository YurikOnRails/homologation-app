class AmoCrmSyncJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform(request_id)
    request = HomologationRequest.find(request_id)
    user = request.user
    client = AmoCrmClient.new

    # Step 1: Find or create Contact with WhatsApp
    contact_id = client.find_or_create_contact(user)
    user.update!(amo_crm_contact_id: contact_id.to_s)

    # Step 2: Create Lead in Homologation pipeline
    lead_id = client.create_lead(request, contact_id)
    request.update!(
      amo_crm_lead_id: lead_id.to_s,
      amo_crm_synced_at: Time.current,
      amo_crm_sync_error: nil
    )

    Rails.logger.info("AmoCRM sync OK: Lead ##{lead_id} for Request ##{request.id}")
  rescue => e
    request&.update_columns(amo_crm_sync_error: e.message)
    raise
  end
end
