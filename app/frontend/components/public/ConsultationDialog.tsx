import { useTranslation } from "react-i18next"
import { usePage } from "@inertiajs/react"
import { CheckCircle2, Clock, Shield, CreditCard, Flame, MessageCircle } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import {
  STRIPE_CONSULTATION_LINK,
  CONTACT_WHATSAPP,
} from "@/lib/constants"
import type { SharedProps } from "@/types"
import type { PublicPageProps } from "@/types/pages"

const CONSULTATION_ITEMS = [
  "consultation_dialog_item_1",
  "consultation_dialog_item_2",
  "consultation_dialog_item_3",
  "consultation_dialog_item_4",
] as const

// Number of spots shown — update manually or connect to backend later
const SPOTS_THIS_WEEK = 3

function buildStripeUrl(stripeLink: string, locale: string): string {
  const separator = stripeLink.includes("?") ? "&" : "?"
  return `${stripeLink}${separator}locale=${locale}`
}

export function ConsultationDialog({
  children,
}: {
  children: React.ReactNode
}) {
  const { t } = useTranslation()
  const props = usePage<SharedProps & PublicPageProps>().props
  const locale = props.seo?.locale ?? "es"

  const hasStripeLink = STRIPE_CONSULTATION_LINK.length > 0 &&
    !STRIPE_CONSULTATION_LINK.includes("REPLACE")

  return (
    <Dialog>
      <DialogTrigger asChild>{children}</DialogTrigger>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle className="text-lg">
            {t("public.homologacion.consultation_dialog_title")}
          </DialogTitle>
          <DialogDescription>
            {t("public.homologacion.consultation_dialog_desc")}
          </DialogDescription>
        </DialogHeader>

        {/* Price & duration */}
        <div className="flex items-center gap-3">
          <span className="text-3xl font-bold bg-gradient-to-r from-brand-primary to-brand-secondary bg-clip-text text-transparent">
            {t("public.homologacion.consultation_dialog_price")}
          </span>
          <Badge variant="secondary" className="gap-1">
            <Clock className="h-3 w-3" />
            {t("public.homologacion.consultation_dialog_duration")}
          </Badge>
        </div>

        {/* What's included */}
        <div className="space-y-3">
          {CONSULTATION_ITEMS.map((key) => (
            <div key={key} className="flex items-start gap-3">
              <CheckCircle2 className="h-4 w-4 text-brand-secondary mt-0.5 shrink-0" />
              <span className="text-sm">{t(`public.homologacion.${key}`)}</span>
            </div>
          ))}
        </div>

        {/* Urgency */}
        <div className="flex items-center gap-2 rounded-lg bg-amber-50 border border-amber-200 px-3 py-2">
          <Flame className="h-4 w-4 text-amber-500 shrink-0" />
          <span className="text-sm font-medium text-amber-800">
            {t("public.homologacion.consultation_dialog_spots", { count: SPOTS_THIS_WEEK })}
          </span>
        </div>

        {/* Pay button or WhatsApp fallback */}
        {hasStripeLink ? (
          <a
            href={buildStripeUrl(STRIPE_CONSULTATION_LINK, locale)}
            rel="noopener noreferrer"
            className="block"
          >
            <Button
              size="lg"
              className="w-full min-h-[44px] text-base bg-gradient-to-r from-brand-primary to-brand-secondary hover:opacity-90 border-0 shadow-lg shadow-brand-secondary/20 transition-all duration-300"
            >
              <CreditCard className="mr-2 h-4 w-4" />
              {t("public.homologacion.consultation_dialog_pay")}
            </Button>
          </a>
        ) : (
          <a
            href={`https://wa.me/${CONTACT_WHATSAPP}?text=${encodeURIComponent(t("public.homologacion.consultation_dialog_wa_message"))}`}
            target="_blank"
            rel="noopener noreferrer"
            className="block"
          >
            <Button
              size="lg"
              className="w-full min-h-[44px] text-base bg-green-600 hover:bg-green-700 border-0 shadow-lg shadow-green-600/20 transition-all duration-300"
            >
              <MessageCircle className="mr-2 h-4 w-4" />
              {t("public.homologacion.consultation_dialog_wa_button")}
            </Button>
          </a>
        )}

        {/* Trust signal */}
        <div className="flex items-center justify-center gap-1.5 text-xs text-muted-foreground">
          <Shield className="h-3 w-3" />
          {hasStripeLink
            ? t("public.homologacion.consultation_dialog_secure")
            : t("public.homologacion.consultation_dialog_wa_hint")}
        </div>
      </DialogContent>
    </Dialog>
  )
}
