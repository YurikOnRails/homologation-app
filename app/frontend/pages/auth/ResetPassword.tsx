import { useForm, usePage } from "@inertiajs/react"
import { useTranslation } from "react-i18next"
import { FormField } from "@/components/auth/FormField"
import { Button } from "@/components/ui/button"
import type { SharedProps } from "@/types"
import type { ResetPasswordProps } from "@/types/pages"
import { routes } from "@/lib/routes"

export default function ResetPassword() {
  const { t } = useTranslation()
  const { token } = usePage<SharedProps & ResetPasswordProps>().props
  const { data, setData, put, processing, errors } = useForm({
    password: "",
    password_confirmation: "",
  })

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    put(routes.password(token))
  }

  return (
    <div className="space-y-6">
      <div className="space-y-1">
        <h1 className="text-2xl font-semibold tracking-tight">{t("auth.reset_password")}</h1>
      </div>

      <form onSubmit={handleSubmit} className="space-y-4">
        <FormField
          id="password"
          label={t("auth.password")}
          type="password"
          autoComplete="new-password"
          value={data.password}
          onChange={(v) => setData("password", v)}
          error={errors.password}
          required
        />

        <FormField
          id="password_confirmation"
          label={t("auth.confirm_password")}
          type="password"
          autoComplete="new-password"
          value={data.password_confirmation}
          onChange={(v) => setData("password_confirmation", v)}
          error={errors.password_confirmation}
          required
        />

        <Button type="submit" className="w-full" size="lg" disabled={processing}>
          {processing ? t("common.loading") : t("auth.reset_password")}
        </Button>
      </form>
    </div>
  )
}
