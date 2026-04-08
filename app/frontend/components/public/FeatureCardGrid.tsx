import { useTranslation } from "react-i18next"
import type { LucideIcon } from "lucide-react"
import { Card, CardContent } from "@/components/ui/card"
import { Reveal, TiltCard } from "@/components/public/animations"

interface FeatureCardItem {
  icon: LucideIcon
  titleKey: string
  descKey: string
}

interface FeatureCardGridProps {
  items: readonly FeatureCardItem[]
  columns?: 2 | 3 | 4
}

const columnClasses: Record<2 | 3 | 4, string> = {
  2: "grid gap-6 sm:grid-cols-2",
  3: "grid gap-6 sm:grid-cols-3",
  4: "grid gap-6 sm:grid-cols-2 lg:grid-cols-4",
}

export function FeatureCardGrid({ items, columns = 4 }: FeatureCardGridProps) {
  const { t } = useTranslation()

  return (
    <div className={columnClasses[columns]}>
      {items.map(({ icon: Icon, titleKey, descKey }, i) => (
        <Reveal key={titleKey} direction="up" delay={i * 120} className="h-full">
          <TiltCard className="h-full">
            <Card className="h-full border bg-white transition-all duration-300 hover:shadow-xl hover:shadow-[#2D7FF9]/5 group">
              <CardContent className="h-full p-6 text-center flex flex-col items-center">
                <div className="mx-auto mb-4 inline-flex rounded-lg bg-gradient-to-br from-[#E8453C]/10 to-[#2D7FF9]/10 p-3 transition-transform duration-300 group-hover:scale-110">
                  <Icon className="h-6 w-6 text-[#2D7FF9]" />
                </div>
                <h3 className="font-semibold mb-2">{t(titleKey)}</h3>
                <p className="text-sm text-muted-foreground">{t(descKey)}</p>
              </CardContent>
            </Card>
          </TiltCard>
        </Reveal>
      ))}
    </div>
  )
}
