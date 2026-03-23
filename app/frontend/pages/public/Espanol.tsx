import { usePage } from "@inertiajs/react"
import { useTranslation } from "react-i18next"
import { Languages, Users, Monitor, User, Star } from "lucide-react"
import { PublicLayout } from "@/components/layout/PublicLayout"
import { Card, CardContent } from "@/components/ui/card"
import { SeoHead } from "@/components/public/SeoHead"
import { Reveal, TiltCard } from "@/components/public/animations"
import {
  GradientButton,
  PublicHero,
  PublicCta,
  PublicSection,
  SectionHeading,
} from "@/components/public/shared"
import { publicRoute, publicPages } from "@/lib/routes"
import type { SharedProps } from "@/types"
import type { PublicPageProps } from "@/types/pages"

export default function Espanol() {
  const { seo } = usePage<SharedProps & PublicPageProps>().props
  const { t } = useTranslation()
  const locale = seo.locale

  const consultaHref = publicRoute(publicPages.consulta, locale)

  return (
    <PublicLayout>
      <SeoHead {...seo} />

      {/* Hero */}
      <PublicHero
        title1={t("public.espanol.hero_title_1")}
        titleAccent={t("public.espanol.hero_title_accent")}
        subtitle={t("public.espanol.hero_subtitle")}
        actions={
          <GradientButton href={consultaHref}>
            {t("public.espanol.cta_trial")}
          </GradientButton>
        }
      />

      {/* Formats */}
      <PublicSection className="bg-white">
        <SectionHeading title={t("public.espanol.formats_title")} />
        <div className="grid gap-6 sm:grid-cols-3">
          {[
            { icon: User, key: "individual" },
            { icon: Users, key: "group" },
            { icon: Monitor, key: "online" },
          ].map(({ icon: Icon, key }, i) => (
            <Reveal key={key} direction="up" delay={i * 120}>
              <TiltCard>
                <Card className="border bg-white transition-all duration-300 hover:shadow-xl hover:shadow-[#2D7FF9]/5 group">
                  <CardContent className="p-8 text-center">
                    <div className="mx-auto mb-4 inline-flex rounded-lg bg-gradient-to-br from-[#E8453C]/10 to-[#2D7FF9]/10 p-3 transition-transform duration-300 group-hover:scale-110">
                      <Icon className="h-6 w-6 text-[#2D7FF9]" />
                    </div>
                    <h3 className="text-lg font-semibold mb-2">
                      {t(`public.espanol.format_${key}_title`)}
                    </h3>
                    <p className="text-sm text-muted-foreground">
                      {t(`public.espanol.format_${key}_desc`)}
                    </p>
                  </CardContent>
                </Card>
              </TiltCard>
            </Reveal>
          ))}
        </div>
      </PublicSection>

      {/* Levels */}
      <PublicSection className="bg-slate-50" dots>
        <SectionHeading title={t("public.espanol.levels_title")} />
        <div className="grid gap-4 grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 max-w-4xl mx-auto">
          {["A1", "A2", "B1", "B2", "C1", "C2"].map((level, i) => (
            <Reveal key={level} direction="up" delay={i * 60}>
              <Card className="border bg-white transition-all duration-300 hover:shadow-md hover:border-[#2D7FF9]/20 hover:-translate-y-1 group">
                <CardContent className="p-6 text-center">
                  <div className="text-2xl font-bold bg-gradient-to-r from-[#E8453C] to-[#2D7FF9] bg-clip-text text-transparent mb-2 transition-transform duration-300 group-hover:scale-110">
                    {level}
                  </div>
                  <p className="text-xs text-muted-foreground">
                    {t(`public.espanol.level_${level.toLowerCase()}`)}
                  </p>
                </CardContent>
              </Card>
            </Reveal>
          ))}
        </div>
      </PublicSection>

      {/* Teachers */}
      <PublicSection className="bg-white">
        <SectionHeading title={t("public.espanol.teachers_title")} />
        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3 max-w-4xl mx-auto">
          {Array.from({ length: 3 }, (_, i) => (
            <Reveal key={i} direction="up" delay={i * 120}>
              <Card className="border bg-white transition-all duration-300 hover:shadow-lg group">
                <CardContent className="p-6 text-center">
                  <div className="mx-auto w-20 h-20 rounded-full bg-gradient-to-br from-[#E8453C]/10 to-[#2D7FF9]/10 flex items-center justify-center mb-4 transition-transform duration-300 group-hover:scale-105 ring-4 ring-white shadow-md">
                    <Languages className="h-8 w-8 text-[#2D7FF9]/50" />
                  </div>
                  <h3 className="font-semibold">
                    {t(`public.espanol.teacher_${i + 1}_name`)}
                  </h3>
                  <p className="text-sm text-muted-foreground mt-1">
                    {t(`public.espanol.teacher_${i + 1}_desc`)}
                  </p>
                  <div className="flex justify-center gap-0.5 mt-3">
                    {Array.from({ length: 5 }, (_, j) => (
                      <Star
                        key={j}
                        className="h-4 w-4 fill-amber-400 text-amber-400"
                      />
                    ))}
                  </div>
                </CardContent>
              </Card>
            </Reveal>
          ))}
        </div>
      </PublicSection>

      {/* CTA */}
      <PublicCta
        title={t("public.espanol.cta_title")}
        subtitle={t("public.espanol.cta_subtitle")}
      >
        <GradientButton href={consultaHref}>
          {t("public.espanol.cta_trial")}
        </GradientButton>
      </PublicCta>
    </PublicLayout>
  )
}
