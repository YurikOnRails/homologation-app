require "test_helper"

class AnalyticsIntegrationTest < ActionDispatch::IntegrationTest
  test "emits Consent Mode v2 defaults in HTML head" do
    get localized_home_path(locale: "en")
    assert_match %r{gtag\('consent', 'default'}, response.body
    assert_match %r{'ad_storage': 'denied'}, response.body
    assert_match %r{'analytics_storage': 'denied'}, response.body
    assert_match %r{'security_storage': 'granted'}, response.body
  end

  test "GTM snippet not rendered in test env even with GTM_ID" do
    with_env("GTM_ID" => "GTM-TEST123") do
      get localized_home_path(locale: "en")
      refute_match %r{googletagmanager\.com/gtm\.js}, response.body
    end
  end

  test "renders Google site verification meta tag when env set" do
    with_env("GOOGLE_SITE_VERIFICATION" => "google-token-abc") do
      get localized_home_path(locale: "en")
      assert_match %r{<meta name="google-site-verification" content="google-token-abc"}, response.body
    end
  end

  test "renders Yandex verification meta tag when env set" do
    with_env("YANDEX_VERIFICATION" => "yandex-xyz789") do
      get localized_home_path(locale: "en")
      assert_match %r{<meta name="yandex-verification" content="yandex-xyz789"}, response.body
    end
  end

  test "renders Bing verification meta tag when env set" do
    with_env("BING_SITE_VERIFICATION" => "bing-validate-456") do
      get localized_home_path(locale: "en")
      assert_match %r{<meta name="msvalidate\.01" content="bing-validate-456"}, response.body
    end
  end

  test "renders Facebook domain verification when env set" do
    with_env("FACEBOOK_DOMAIN_VERIFICATION" => "fb-domain-123") do
      get localized_home_path(locale: "en")
      assert_match %r{<meta name="facebook-domain-verification" content="fb-domain-123"}, response.body
    end
  end

  test "no verification meta tags when env vars absent" do
    get localized_home_path(locale: "en")
    refute_match %r{google-site-verification}, response.body
    refute_match %r{yandex-verification}, response.body
    refute_match %r{msvalidate\.01}, response.body
  end

  private

  def with_env(vars)
    original = vars.keys.index_with { |k| ENV[k] }
    vars.each { |k, v| ENV[k] = v }
    yield
  ensure
    original.each { |k, v| v.nil? ? ENV.delete(k) : ENV[k] = v }
  end
end
