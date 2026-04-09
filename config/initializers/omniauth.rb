OmniAuth.config.allowed_request_methods = [ :post ]
OmniAuth.config.silence_get_warning = true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
    Rails.application.credentials.dig(:google, :client_id) || "placeholder",
    Rails.application.credentials.dig(:google, :client_secret) || "placeholder",
    { scope: "email,profile", prompt: "select_account" }

  provider :facebook,
    Rails.application.credentials.dig(:facebook, :app_id) || "placeholder",
    Rails.application.credentials.dig(:facebook, :app_secret) || "placeholder",
    { scope: "email,public_profile", info_fields: "email,name" }
end
