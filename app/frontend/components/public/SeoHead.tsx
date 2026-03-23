import { Head } from "@inertiajs/react"

export interface SeoProps {
  title: string
  description: string
  locale: string
  alternates: { locale: string; url: string }[]
  ogImage?: string
}

export function SeoHead({ title, description, locale, alternates, ogImage }: SeoProps) {
  return (
    <Head>
      <title>{title}</title>
      <meta name="description" content={description} />
      <meta property="og:title" content={title} />
      <meta property="og:description" content={description} />
      {ogImage && <meta property="og:image" content={ogImage} />}
      <meta property="og:type" content="website" />
      <html lang={locale} />
      {alternates.map(({ locale: l, url }) => (
        <link key={l} rel="alternate" hrefLang={l} href={url} />
      ))}
      <link rel="alternate" hrefLang="x-default" href={alternates.find(a => a.locale === "en")?.url ?? alternates[0]?.url} />
    </Head>
  )
}
