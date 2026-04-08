import { useTranslation } from "react-i18next"
import { Reveal } from "@/components/public/animations"

interface TimelineSectionProps {
  translationPrefix: string
  count: number
  /** Translation key pattern for title, e.g. "process" produces `${prefix}.process_1_title`. Default: "process" */
  keyPattern?: string
}

export function TimelineSection({
  translationPrefix,
  count,
  keyPattern = "process",
}: TimelineSectionProps) {
  const { t } = useTranslation()

  return (
    <div className="max-w-3xl mx-auto space-y-8">
      {Array.from({ length: count }, (_, i) => (
        <Reveal key={i} direction="left" delay={i * 150}>
          <div className="flex gap-6 items-start group">
            <div className="shrink-0 w-10 h-10 rounded-full bg-gradient-to-r from-[#E8453C] to-[#2D7FF9] text-white flex items-center justify-center font-bold text-sm shadow-md transition-all duration-300 group-hover:scale-110 group-hover:shadow-lg group-hover:shadow-[#2D7FF9]/20">
              {i + 1}
            </div>
            <div>
              <h3 className="font-semibold">
                {t(`${translationPrefix}.${keyPattern}_${i + 1}_title`)}
              </h3>
              <p className="text-sm text-muted-foreground mt-1">
                {t(`${translationPrefix}.${keyPattern}_${i + 1}_desc`)}
              </p>
            </div>
          </div>
        </Reveal>
      ))}
    </div>
  )
}
