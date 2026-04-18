xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9",
           "xmlns:xhtml" => "http://www.w3.org/1999/xhtml" do
  @pages.each do |page|
    suffix = page[:path] == "/" ? "" : page[:path]

    @locales.each do |locale|
      xml.url do
        xml.loc "#{@base_url}/#{locale}#{suffix}"
        xml.lastmod @lastmod
        xml.changefreq page[:changefreq]
        xml.priority page[:priority]

        @locales.each do |alt_locale|
          xml.xhtml :link,
                    rel: "alternate",
                    hreflang: alt_locale,
                    href: "#{@base_url}/#{alt_locale}#{suffix}"
        end
        xml.xhtml :link,
                  rel: "alternate",
                  hreflang: "x-default",
                  href: "#{@base_url}/en#{suffix}"
      end
    end
  end

  xml.url do
    xml.loc "#{@base_url}/privacy-policy"
    xml.lastmod @lastmod
    xml.changefreq "yearly"
    xml.priority "0.3"
  end
end
