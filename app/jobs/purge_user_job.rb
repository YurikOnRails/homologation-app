class PurgeUserJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return if user.nil? || user.purge_scheduled_at.nil?

    user.purge_everything!
  end
end
