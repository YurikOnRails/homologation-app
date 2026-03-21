import { useTranslation } from "react-i18next"
import { Badge } from "@/components/ui/badge"
import { PipelineCard } from "@/components/pipeline/PipelineCard"
import type { PipelineCard as PipelineCardType } from "@/types/pages"

interface KanbanColumnProps {
  stage: string
  cards: PipelineCardType[]
  onEditCard: (card: PipelineCardType) => void
}

export function KanbanColumn({ stage, cards, onEditCard }: KanbanColumnProps) {
  const { t } = useTranslation()

  return (
    <div className="w-72 flex-shrink-0">
      <div className="flex items-center justify-between mb-3">
        <h3 className="text-sm font-semibold">{t(`pipeline.stages.${stage}`)}</h3>
        <Badge variant="secondary">{cards.length}</Badge>
      </div>
      <div className="space-y-3 max-h-[calc(100vh-320px)] overflow-y-auto">
        {cards.map((card) => (
          <PipelineCard key={card.id} card={card} onEdit={onEditCard} />
        ))}
      </div>
    </div>
  )
}
