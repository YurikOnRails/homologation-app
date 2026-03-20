import { useForm, usePage, router } from "@inertiajs/react"
import { useTranslation } from "react-i18next"
import { AuthenticatedLayout } from "@/components/layout/AuthenticatedLayout"
import { Main } from "@/components/layout/Main"
import { SettingsLayout } from "@/components/settings/SettingsLayout"
import { Button } from "@/components/ui/button"
import { Label } from "@/components/ui/label"
import { Separator } from "@/components/ui/separator"
import { Switch } from "@/components/ui/switch"
import { routes } from "@/lib/routes"
import type { SharedProps } from "@/types"
import type { SettingsNotificationsProps } from "@/types/pages"

export default function SettingsNotifications() {
  const { t } = useTranslation()
  const { notifications } = usePage<SharedProps & SettingsNotificationsProps>().props

  const { data, setData, patch, processing } = useForm({
    notification_email: notifications.notificationEmail,
    notification_telegram: notifications.notificationTelegram,
  })

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    patch(routes.settings.notifications)
  }

  function handleConnectTelegram() {
    router.post(routes.settings.connectTelegram)
  }

  function handleDisconnectTelegram() {
    router.delete(routes.settings.disconnectTelegram)
  }

  return (
    <AuthenticatedLayout
      breadcrumbs={[
        { label: t("nav.settings"), href: routes.settings.notifications },
        { label: t("settings.nav.notifications") },
      ]}
    >
      <Main>
        <div className="mb-6">
          <h1 className="text-2xl font-bold tracking-tight">{t("settings.title")}</h1>
          <p className="text-sm text-muted-foreground">{t("settings.description")}</p>
        </div>
        <Separator className="mb-6" />
        <SettingsLayout>
          <div className="space-y-6">
            <div>
              <h2 className="text-lg font-semibold">{t("settings.nav.notifications")}</h2>
              <p className="text-sm text-muted-foreground">{t("settings.notifications.description")}</p>
            </div>
            <Separator />
            <form onSubmit={handleSubmit} className="space-y-6 max-w-lg">
              {/* Email notifications */}
              <div className="space-y-3">
                <h3 className="text-sm font-medium">{t("settings.notifications.email_title")}</h3>
                <div className="flex items-center justify-between rounded-lg border p-4">
                  <div className="space-y-0.5">
                    <Label htmlFor="notification_email" className="text-sm font-medium cursor-pointer">
                      {t("profile.email_notifications")}
                    </Label>
                    <p className="text-xs text-muted-foreground">
                      {t("settings.notifications.email_hint")}
                    </p>
                  </div>
                  <Switch
                    id="notification_email"
                    checked={data.notification_email}
                    onCheckedChange={(checked) => setData("notification_email", checked)}
                  />
                </div>
              </div>

              {/* Telegram */}
              <div className="space-y-3">
                <h3 className="text-sm font-medium">{t("settings.notifications.telegram_title")}</h3>
                <div className="rounded-lg border p-4 space-y-4">
                  <div className="flex items-start justify-between gap-4">
                    <div className="space-y-1">
                      <p className="text-sm font-medium">
                        {notifications.telegramConnected
                          ? `✓ ${t("profile.telegram_connected")}`
                          : "Telegram"}
                      </p>
                      <p className="text-xs text-muted-foreground">{t("profile.telegram_hint")}</p>
                    </div>
                    {notifications.telegramConnected ? (
                      <Button
                        type="button"
                        variant="outline"
                        size="sm"
                        className="min-h-[44px] shrink-0"
                        onClick={handleDisconnectTelegram}
                      >
                        {t("profile.disconnect_telegram")}
                      </Button>
                    ) : (
                      <Button
                        type="button"
                        size="sm"
                        className="min-h-[44px] shrink-0"
                        onClick={handleConnectTelegram}
                      >
                        {t("profile.connect_telegram")}
                      </Button>
                    )}
                  </div>

                  {notifications.telegramConnected && (
                    <div className="flex items-center justify-between rounded-lg border p-4">
                      <div className="space-y-0.5">
                        <Label htmlFor="notification_telegram" className="text-sm font-medium cursor-pointer">
                          {t("profile.telegram_notifications")}
                        </Label>
                        <p className="text-xs text-muted-foreground">
                          {t("settings.notifications.telegram_hint")}
                        </p>
                      </div>
                      <Switch
                        id="notification_telegram"
                        checked={data.notification_telegram}
                        onCheckedChange={(checked) => setData("notification_telegram", checked)}
                      />
                    </div>
                  )}
                </div>
              </div>

              <Button type="submit" className="min-h-[44px]" disabled={processing}>
                {t("settings.notifications.save")}
              </Button>
            </form>
          </div>
        </SettingsLayout>
      </Main>
    </AuthenticatedLayout>
  )
}
