class AmoCrmSyncJob < ApplicationJob
  queue_as :default

  def perform(request_id)
    # TODO Step 6: Implement AmoCRM sync via AmoCrmClient
  end
end
