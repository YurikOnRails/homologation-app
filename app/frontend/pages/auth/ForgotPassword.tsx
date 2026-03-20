import { useForm, Link } from "@inertiajs/react"
import { useTranslation } from "react-i18next"
import { FormField } from "@/components/auth/FormField"
import { Button } from "@/components/ui/button"
import { routes } from "@/lib/routes"

export default function ForgotPassword() {
  const { t } = useTranslation()
  const { data, setData, post, processing, errors } = useForm({
    email_address: "",
  })

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    post(routes.passwords)
  }

  return (
    <div className="space-y-6">
      <div className="space-y-1">
        <h1 className="text-2xl font-semibold tracking-tight">{t("auth.forgot_password")}</h1>
        <p className="text-sm text-muted-foreground">
          {t("auth.forgot_password_hint")}
        </p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-4">
        <FormField
          id="email_address"
          label={t("auth.email")}
          type="email"
          autoComplete="email"
          value={data.email_address}
          onChange={(v) => setData("email_address", v)}
          error={errors.email_address}
          required
        />

        <Button type="submit" className="w-full" size="lg" disabled={processing}>
          {processing ? t("common.loading") : t("auth.reset_password")}
        </Button>
      </form>

      <p className="text-center text-sm text-muted-foreground">
        <Link href={routes.login} className="text-foreground underline underline-offset-4 hover:text-primary">
          {t("auth.sign_in")}
        </Link>
      </p>
    </div>
  )
}
