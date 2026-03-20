import { useForm, Link } from "@inertiajs/react"
import { useTranslation } from "react-i18next"
import { OAuthButtons } from "@/components/auth/OAuthButtons"
import { FormField } from "@/components/auth/FormField"
import { Button } from "@/components/ui/button"
import { Label } from "@/components/ui/label"
import { Separator } from "@/components/ui/separator"
import { routes } from "@/lib/routes"

export default function Login() {
  const { t } = useTranslation()
  const { data, setData, post, processing, errors } = useForm({
    email_address: "",
    password: "",
  })

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    post(routes.session)
  }

  return (
    <div className="space-y-6">
      <div className="space-y-1">
        <h1 className="text-2xl font-semibold tracking-tight">{t("auth.sign_in")}</h1>
        <p className="text-sm text-muted-foreground">
          {t("auth.no_account")}{" "}
          <Link href={routes.register} className="text-foreground underline underline-offset-4 hover:text-primary">
            {t("auth.sign_up")}
          </Link>
        </p>
      </div>

      <OAuthButtons />

      <div className="relative">
        <Separator />
        <span className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 bg-background px-2 text-xs text-muted-foreground">
          {t("auth.or_email")}
        </span>
      </div>

      <form onSubmit={handleSubmit} className="space-y-4">
        <FormField
          id="email_address"
          label={t("auth.email")}
          type="email"
          autoComplete="email"
          placeholder="nombre@ejemplo.com"
          value={data.email_address}
          onChange={(v) => setData("email_address", v)}
          error={errors.email_address}
          required
        />

        <div>
          <div className="flex items-center justify-between mb-2">
            <Label htmlFor="password">{t("auth.password")}</Label>
            <Link
              href={routes.forgotPassword}
              className="text-xs text-muted-foreground underline underline-offset-4 hover:text-foreground"
            >
              {t("auth.forgot_password")}
            </Link>
          </div>
          <FormField
            id="password"
            type="password"
            autoComplete="current-password"
            value={data.password}
            onChange={(v) => setData("password", v)}
            error={errors.password}
            required
          />
        </div>

        <Button type="submit" className="w-full" size="lg" disabled={processing}>
          {processing ? t("common.loading") : t("auth.sign_in")}
        </Button>
      </form>

      <p className="text-center text-xs text-muted-foreground">
        {t("auth.privacy_notice")}{" "}
        <Link href={routes.privacyPolicy} className="underline underline-offset-4 hover:text-foreground">
          {t("privacy.title")}
        </Link>
      </p>
    </div>
  )
}
