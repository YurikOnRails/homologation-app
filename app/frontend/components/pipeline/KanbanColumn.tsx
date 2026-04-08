import { useTranslation } from "react-i18next"
import { PipelineCard } from "@/components/pipeline/PipelineCard"
import { usePipeline } from "@/components/pipeline/constants"
import type { PipelineCard as PipelineCardType } from "@/types/pages"

interface KanbanColumnProps {
  stage: string
  cards: PipelineCardType[]
  onEditCard: (card: PipelineCardType) => void
}

export function KanbanColumn({ stage, cards, onEditCard }: KanbanColumnProps) {
  const { t } = useTranslation()
  const { stageColors } = usePipeline()
  const color = stageColors[stage]

  return (
    <div className="w-72 flex-shrink-0">
      {/* Column header with icon */}
      <div className="flex items-center gap-2 mb-3 pb-2 border-b border-border">
        <span className="text-base">{color?.icon}</span>
        <h3 className="text-sm font-semibold flex-1">
          {t(`pipeline.stages.${stage}`)}
          {stage === "traduccion" && (
            <span className="ml-1.5 text-[10px] font-medium px-1 py-0.5 rounded bg-muted text-muted-foreground">
              cond.
            </span>
          )}
        </h3>
        <span className="text-sm font-medium text-muted-foreground tabular-nums">
          ({cards.length})
        </span>
      </div>
      {/* Cards */}
      <div className="space-y-2.5 max-h-[calc(100vh-320px)] overflow-y-auto pr-1">
        {cards.map((card) => (
          <PipelineCard key={card.id} card={card} stage={stage} onEdit={onEditCard} />
        ))}
        {cards.length === 0 && (
          <p className="text-xs text-muted-foreground py-6 text-center">
            {t("pipeline.no_cards")}
          </p>
        )}
      </div>
    </div>
  )
}
