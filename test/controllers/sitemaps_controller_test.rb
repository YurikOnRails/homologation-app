require "test_helper"

class SitemapsControllerTest < ActionDispatch::IntegrationTest
  test "sitemap.xml returns XML with all pages in all locales" do
    get sitemap_path
    assert_response :ok
    assert_equal "application/xml", response.media_type

    %w[en es ru].each do |locale|
      assert_match %r{<loc>[^<]*/#{locale}</loc>}, response.body,
                   "sitemap should include home for /#{locale}"
      assert_match %r{<loc>[^<]*/#{locale}/homologation</loc>}, response.body
      assert_match %r{<loc>[^<]*/#{locale}/university</loc>}, response.body
      assert_match %r{<loc>[^<]*/#{locale}/spanish</loc>}, response.body
      assert_match %r{<loc>[^<]*/#{locale}/pricing</loc>}, response.body
    end
  end

  test "sitemap.xml includes hreflang alternate links" do
    get sitemap_path
    assert_match %r{xmlns:xhtml="http://www.w3.org/1999/xhtml"}, response.body
    assert_match %r{<xhtml:link[^/]+rel="alternate"[^/]+hreflang="en"}, response.body
    assert_match %r{<xhtml:link[^/]+rel="alternate"[^/]+hreflang="es"}, response.body
    assert_match %r{<xhtml:link[^/]+rel="alternate"[^/]+hreflang="ru"}, response.body
    assert_match %r{hreflang="x-default"}, response.body
  end

  test "sitemap.xml includes privacy policy" do
    get sitemap_path
    assert_match %r{<loc>[^<]*/privacy-policy</loc>}, response.body
  end

  test "robots.txt returns text with sitemap directive" do
    get robots_path
    assert_response :ok
    assert_match %r{^Sitemap: .*?/sitemap\.xml}m, response.body
  end

  test "robots.txt allows public content and disallows private paths" do
    get robots_path
    assert_match %r{^User-agent: \*}m, response.body
    assert_match %r{^Disallow: /admin/}m, response.body
    assert_match %r{^Disallow: /settings/}m, response.body
    assert_match %r{^Disallow: /dashboard}m, response.body
  end

  test "robots.txt explicitly allows AI crawlers" do
    get robots_path
    assert_match %r{^User-agent: GPTBot}m, response.body
    assert_match %r{^User-agent: ClaudeBot}m, response.body
    assert_match %r{^User-agent: PerplexityBot}m, response.body
  end
end
