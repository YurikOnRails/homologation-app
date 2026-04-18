// Consent Mode v2 integration.
// Defaults are set inline in application.html.erb BEFORE gtm.js. This module
// only pushes updates after the user makes a choice in the CMP.

type ConsentCategory = "necessary" | "analytics" | "marketing"

type ConsentSignal = "granted" | "denied"

interface ConsentUpdate {
  analytics_storage: ConsentSignal
  ad_storage: ConsentSignal
  ad_user_data: ConsentSignal
  ad_personalization: ConsentSignal
  personalization_storage: ConsentSignal
  functionality_storage: ConsentSignal
}

declare global {
  interface Window {
    dataLayer?: unknown[]
    gtag?: (...args: unknown[]) => void
  }
}

function ensureGtag(): (...args: unknown[]) => void {
  window.dataLayer = window.dataLayer || []
  if (!window.gtag) {
    window.gtag = function gtag(...args: unknown[]) {
      window.dataLayer!.push(args)
    }
  }
  return window.gtag
}

export function syncConsentMode(categories: ConsentCategory[]): void {
  const gtag = ensureGtag()
  const analytics = categories.includes("analytics") ? "granted" : "denied"
  const marketing = categories.includes("marketing") ? "granted" : "denied"

  const update: ConsentUpdate = {
    analytics_storage: analytics,
    ad_storage: marketing,
    ad_user_data: marketing,
    ad_personalization: marketing,
    personalization_storage: analytics,
    functionality_storage: analytics,
  }
  gtag("consent", "update", update)
  // Push an explicit dataLayer event so GTM triggers can fire on consent change
  window.dataLayer!.push({ event: "consent_updated", consent_categories: categories })
}

export function detectLocale(): "en" | "es" | "ru" {
  const match = window.location.pathname.match(/^\/([a-z]{2})(?:\/|$)/)
  const lang = match?.[1]
  if (lang === "es" || lang === "en" || lang === "ru") return lang
  const htmlLang = document.documentElement.lang?.slice(0, 2)
  if (htmlLang === "es" || htmlLang === "en" || htmlLang === "ru") return htmlLang
  return "en"
}
