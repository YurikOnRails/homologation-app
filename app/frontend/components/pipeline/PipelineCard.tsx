import { useState } from "react"
import { router, usePage } from "@inertiajs/react"
import { useTranslation } from "react-i18next"
import { Card, CardContent } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip"
import { DocumentTags } from "@/components/pipeline/DocumentTags"
import { STAGE_COLORS } from "@/components/pipeline/constants"
import { routes } from "@/lib/routes"
import { cn, getOptionLabel } from "@/lib/utils"
import type { SharedProps } from "@/types"
import type { PipelineCard as PipelineCardType } from "@/types/pages"

interface PipelineCardProps {
  card: PipelineCardType
  stage?: string
  onEdit: (card: PipelineCardType) => void
}

export function PipelineCard({ card, stage, onEdit }: PipelineCardProps) {
  const { t, i18n } = useTranslation()
  const { selectOptions } = usePage<SharedProps>().props
  const [busy, setBusy] = useState(false)
  const stageKey = stage ?? card.pipelineStage
  const color = STAGE_COLORS[stageKey]

  const countryLabel = card.country
    ? (selectOptions.countries ?? []).find((o) => o.key === card.country)
    : null
  const countryName = countryLabel
    ? getOptionLabel(countryLabel, i18n.language)
    : card.country

  function advance(e: React.MouseEvent) {
    e.stopPropagation()
    if (busy) return
    setBusy(true)
    router.patch(routes.admin.pipelineAdvance(card.id), {}, {
      preserveScroll: true,
      preserveState: true,
      onFinish: () => setBusy(false),
    })
  }

  function retreat(e: React.MouseEvent) {
    e.stopPropagation()
    if (busy) return
    setBusy(true)
    router.patch(routes.admin.pipelineRetreat(card.id), {}, {
      preserveScroll: true,
      preserveState: true,
      onFinish: () => setBusy(false),
    })
  }

  return (
    <Card
      className={cn(
        "cursor-pointer hover:shadow-md transition-all border-l-4",
        color?.border ?? "border-l-gray-300"
      )}
      onClick={() => onEdit(card)}
    >
      <CardContent className="p-3 space-y-2">
        {/* Row 1: Name + amount */}
        <div className="flex items-start justify-between gap-2">
          <div className="min-w-0">
            <p className="font-semibold text-sm truncate">{card.studentName}</p>
            {card.phone && (
              <p className="text-xs text-muted-foreground">{card.phone}</p>
            )}
          </div>
          <span className="text-xs font-bold text-foreground whitespace-nowrap">
            {card.amount}&euro;
          </span>
        </div>

        {/* Row 2: Badges */}
        <div className="flex items-center gap-1 flex-wrap">
          <span className="text-[11px] font-bold px-1.5 py-0.5 rounded bg-blue-600 text-white">
            {card.year}
          </span>
          <span className="text-[11px] font-bold px-1.5 py-0.5 rounded bg-pink-600 text-white">
            {card.serviceType}
          </span>
          {card.country && (
            <Tooltip>
              <TooltipTrigger asChild>
                <span className="inline-flex items-center gap-1 text-[11px] font-bold px-1.5 py-0.5 rounded bg-emerald-600 text-white cursor-default">
                  <span className={`fi fi-${card.country.toLowerCase()} rounded-sm`} />
                  {card.country}
                </span>
              </TooltipTrigger>
              <TooltipContent side="top">
                <p>{countryName}</p>
              </TooltipContent>
            </Tooltip>
          )}
          {card.countryMissing && (
            <span className="text-[11px] font-bold px-1.5 py-0.5 rounded bg-red-500 text-white">?</span>
          )}
        </div>

        {/* Row 3: Notes */}
        {card.pipelineNotes && (
          <p className="text-xs text-muted-foreground line-clamp-2">{card.pipelineNotes}</p>
        )}

        {/* Row 4: Document tags */}
        <DocumentTags
          checklist={card.documentChecklist}
          complete={card.documentsComplete}
          total={card.documentsTotal}
        />

        {/* Row 5: Actions */}
        <div className="flex items-center gap-1.5 pt-0.5">
          {card.canRetreat && (
            <Button
              variant="ghost"
              size="sm"
              className="h-8 flex-1 text-xs"
              disabled={busy}
              onClick={retreat}
            >
              &larr;
            </Button>
          )}
          {card.canAdvance && (
            <Button
              size="sm"
              className="h-8 flex-1 text-xs bg-emerald-700/85 hover:bg-emerald-700 text-white"
              disabled={busy}
              onClick={advance}
            >
              {t("pipeline.advance")} &rarr;
            </Button>
          )}
        </div>
      </CardContent>
    </Card>
  )
}
