# frozen_string_literal: true

module AnalyticsHelper
  def gtm_id
    ENV["GTM_ID"].presence
  end

  def gtm_enabled?
    gtm_id.present? && !Rails.env.test?
  end

  def webmaster_verifications
    {
      "google-site-verification" => ENV["GOOGLE_SITE_VERIFICATION"].presence,
      "yandex-verification"      => ENV["YANDEX_VERIFICATION"].presence,
      "msvalidate.01"            => ENV["BING_SITE_VERIFICATION"].presence,
      "facebook-domain-verification" => ENV["FACEBOOK_DOMAIN_VERIFICATION"].presence
    }.compact
  end

  def sentry_frontend_meta
    dsn = ENV["SENTRY_DSN_FRONTEND"].presence
    return {} if dsn.nil? || Rails.env.test?
    {
      "sentry-dsn" => dsn,
      "sentry-environment" => ENV["SENTRY_ENVIRONMENT"].presence || Rails.env,
      "sentry-release" => ENV["SENTRY_RELEASE"].presence,
      "sentry-traces-sample-rate" => ENV["SENTRY_TRACES_SAMPLE_RATE"].presence
    }.compact
  end

  # Inline script emitted BEFORE GTM loads. Sets all Consent Mode v2 signals to
  # "denied" except security_storage. CMP updates them once the user decides.
  # wait_for_update: GTM buffers events for 500 ms to let consent state arrive
  # before sending cookieless pings.
  def consent_mode_default_script
    <<~JS.html_safe
      window.dataLayer = window.dataLayer || [];
      function gtag(){dataLayer.push(arguments);}
      gtag('consent', 'default', {
        'ad_storage': 'denied',
        'ad_user_data': 'denied',
        'ad_personalization': 'denied',
        'analytics_storage': 'denied',
        'personalization_storage': 'denied',
        'functionality_storage': 'denied',
        'security_storage': 'granted',
        'wait_for_update': 500
      });
    JS
  end

  def gtm_head_script
    return "".html_safe unless gtm_enabled?
    id = gtm_id
    <<~JS.html_safe
      (function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
      new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
      j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
      'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
      })(window,document,'script','dataLayer','#{j id}');
    JS
  end

  def gtm_noscript_iframe_src
    return nil unless gtm_enabled?
    "https://www.googletagmanager.com/ns.html?id=#{CGI.escape(gtm_id)}"
  end
end
