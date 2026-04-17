class SitemapsController < ApplicationController
  allow_unauthenticated_access
  before_action :resume_session

  LOCALIZED_PAGES = [
    { path: "/",             priority: "1.0", changefreq: "weekly" },
    { path: "/homologation", priority: "0.9", changefreq: "monthly" },
    { path: "/university",   priority: "0.9", changefreq: "monthly" },
    { path: "/spanish",      priority: "0.9", changefreq: "monthly" },
    { path: "/pricing",      priority: "0.8", changefreq: "monthly" }
  ].freeze

  LOCALES = %w[en es ru].freeze

  def index
    @base_url = base_url
    @pages = LOCALIZED_PAGES
    @locales = LOCALES
    @lastmod = Time.current.to_date.iso8601
    respond_to do |format|
      format.xml
    end
  end

  def robots
    @sitemap_url = "#{base_url}/sitemap.xml"
    respond_to do |format|
      format.text
    end
  end

  private

  def base_url
    ENV.fetch("APP_HOST_URL") { request.base_url }
  end
end
