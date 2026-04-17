import { usePage } from "@inertiajs/react"
import { useTranslation } from "react-i18next"
import { AuthenticatedLayout } from "@/components/layout/AuthenticatedLayout"
import { AuthLayout } from "@/components/layout/AuthLayout"
import { Button } from "@/components/ui/button"
import { showCookiePreferences } from "@/lib/cookieConsent"
import type { SharedProps } from "@/types"

export default function PrivacyPolicy() {
  const { t } = useTranslation()
  const { auth } = usePage<SharedProps>().props
  const isAuthenticated = !!auth.user

  const content = (
    <div className="mx-auto max-w-2xl space-y-8 px-4 py-8">
      <h1 className="text-2xl font-bold">{t("privacy.title")}</h1>

      <section className="space-y-3">
        <h2 className="text-lg font-semibold">{t("privacy.data_collected_title")}</h2>
        <p className="text-sm text-muted-foreground leading-relaxed">{t("privacy.data_collected_body")}</p>
      </section>

      <section className="space-y-3">
        <h2 className="text-lg font-semibold">{t("privacy.amocrm_title")}</h2>
        <p className="text-sm text-muted-foreground leading-relaxed">{t("privacy.amocrm_body")}</p>
      </section>

      <section className="space-y-3">
        <h2 className="text-lg font-semibold">{t("privacy.cookies_title")}</h2>
        <p className="text-sm text-muted-foreground leading-relaxed">{t("privacy.cookies_body")}</p>
      </section>

      <section className="space-y-3">
        <h2 className="text-lg font-semibold">{t("privacy.analytics_tools_title")}</h2>
        <p className="text-sm text-muted-foreground leading-relaxed">{t("privacy.analytics_tools_body")}</p>
      </section>

      <section className="space-y-3">
        <h2 className="text-lg font-semibold">{t("privacy.manage_consent_title")}</h2>
        <p className="text-sm text-muted-foreground leading-relaxed">{t("privacy.manage_consent_body")}</p>
        <Button variant="outline" onClick={showCookiePreferences} className="min-h-[44px]">
          {t("privacy.manage_consent_button")}
        </Button>
      </section>

      <section className="space-y-3">
        <h2 className="text-lg font-semibold">{t("privacy.deletion_title")}</h2>
        <p className="text-sm text-muted-foreground leading-relaxed">{t("privacy.deletion_body")}</p>
      </section>
    </div>
  )

  if (isAuthenticated) {
    return <AuthenticatedLayout>{content}</AuthenticatedLayout>
  }

  return <AuthLayout>{content}</AuthLayout>
}
