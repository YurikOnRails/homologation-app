import { useTranslation } from "react-i18next"
import { Badge } from "@/components/ui/badge"
import { PipelineCard } from "@/components/pipeline/PipelineCard"
import type { PipelineCard as PipelineCardType } from "@/types/pages"

interface HorizontalGroupProps {
  stage: string
  cards: PipelineCardType[]
  icon: string
  onEditCard: (card: PipelineCardType) => void
}

export function HorizontalGroup({ stage, cards, icon, onEditCard }: HorizontalGroupProps) {
  const { t } = useTranslation()

  return (
    <div className="border-t pt-4">
      <div className="flex items-center gap-2 mb-3">
        <span>{icon}</span>
        <h3 className="text-sm font-semibold">{t(`pipeline.stages.${stage}`)}</h3>
        <Badge variant="secondary">{cards.length}</Badge>
      </div>
      <div className="flex gap-3 overflow-x-auto pb-3">
        {cards.map((card) => (
          <div key={card.id} className="w-64 flex-shrink-0">
            <PipelineCard card={card} onEdit={onEditCard} />
          </div>
        ))}
        {cards.length === 0 && (
          <p className="text-sm text-muted-foreground py-4">{t("pipeline.no_cards")}</p>
        )}
      </div>
    </div>
  )
}
