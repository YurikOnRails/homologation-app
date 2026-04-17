# frozen_string_literal: true

return unless ENV["SENTRY_DSN_BACKEND"].present?

Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN_BACKEND"]
  config.environment = ENV["SENTRY_ENVIRONMENT"].presence || Rails.env
  config.release = ENV["SENTRY_RELEASE"].presence
  config.enabled_environments = %w[production staging]

  config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]

  config.traces_sample_rate   = (ENV["SENTRY_TRACES_SAMPLE_RATE"].presence || "0.1").to_f
  config.profiles_sample_rate = (ENV["SENTRY_PROFILES_SAMPLE_RATE"].presence || "0.0").to_f

  # Never send raw PII. Rails' filter_parameters already scrubs configured fields;
  # this disables IP addresses, cookies, and user identifiers Sentry adds by default.
  config.send_default_pii = false

  config.before_send = lambda do |event, _hint|
    if event.request&.data.is_a?(Hash)
      event.request.data = event.request.data.transform_values do |v|
        v.is_a?(String) && v.length > 1000 ? "[truncated]" : v
      end
    end
    event.request.cookies = nil if event.request.respond_to?(:cookies=)
    event
  end

  config.excluded_exceptions += [
    "ActionController::RoutingError",
    "ActiveRecord::RecordNotFound",
    "Pundit::NotAuthorizedError"
  ]
end
