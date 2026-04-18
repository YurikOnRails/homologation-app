Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data, :blob
    policy.object_src  :none

    script_src_sources  = [ :self ]
    connect_src_sources = [ :self, :https ]

    # Sentry endpoints — wildcard covers ingest.*.sentry.io regional subdomains
    # and self-hosted Sentry if configured on a subdomain.
    if ENV["SENTRY_DSN_FRONTEND"].present?
      connect_src_sources += %w[
        https://*.sentry.io
        https://*.ingest.sentry.io
        https://*.ingest.de.sentry.io
        https://*.ingest.us.sentry.io
      ]
    end

    # When GTM is configured, permit the analytics/marketing domains GTM needs
    # and allow inline scripts (GTM injects tag setup code via document.write and
    # inline event handlers; nonce-based CSP is not practical with GTM).
    if ENV["GTM_ID"].present?
      tracking_script_domains = %w[
        https://www.googletagmanager.com
        https://www.google-analytics.com
        https://ssl.google-analytics.com
        https://mc.yandex.ru
        https://mc.yandex.com
        https://www.clarity.ms
        https://connect.facebook.net
      ]
      tracking_connect_domains = %w[
        https://www.googletagmanager.com
        https://www.google-analytics.com
        https://*.analytics.google.com
        https://mc.yandex.ru
        https://mc.yandex.com
        https://mc.webvisor.org
        https://mc.webvisor.com
        https://*.clarity.ms
        https://www.facebook.com
        https://connect.facebook.net
      ]
      script_src_sources  += [ :unsafe_inline, :unsafe_eval ] + tracking_script_domains
      connect_src_sources += tracking_connect_domains
    end

    policy.script_src      *script_src_sources
    policy.style_src       :self, :unsafe_inline  # Tailwind CSS requires inline styles
    policy.connect_src     *connect_src_sources
    policy.frame_src       :self, "https://www.googletagmanager.com"
    policy.frame_ancestors :none                   # Prevents clickjacking (replaces X-Frame-Options: DENY)
    policy.worker_src      :blob                   # Vite worker bundles

    if Rails.env.development?
      vite_host = "http://#{ViteRuby.config.host_with_port}"
      ws_host   = "ws://#{ViteRuby.config.host_with_port}"
      # :unsafe_inline is required for Vite's React Refresh preamble (inline <script>)
      policy.script_src  *policy.script_src, :unsafe_inline, :unsafe_eval, vite_host
      policy.style_src   *policy.style_src, vite_host
      policy.connect_src *policy.connect_src, vite_host, ws_host
    end
  end
end
