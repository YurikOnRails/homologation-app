import { useState } from "react"
import { router } from "@inertiajs/react"
import { useTranslation } from "react-i18next"
import { Card, CardContent } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { DocumentTags } from "@/components/pipeline/DocumentTags"
import { routes } from "@/lib/routes"
import { countryFlag } from "@/lib/utils"
import type { PipelineCard as PipelineCardType } from "@/types/pages"

interface PipelineCardProps {
  card: PipelineCardType
  onEdit: (card: PipelineCardType) => void
}

export function PipelineCard({ card, onEdit }: PipelineCardProps) {
  const { t } = useTranslation()
  const [busy, setBusy] = useState(false)

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
      className="cursor-pointer hover:bg-muted/50 transition-colors"
      onClick={() => onEdit(card)}
    >
      <CardContent className="p-3 space-y-2">
        {/* Row 1: Name + phone */}
        <div>
          <p className="font-semibold text-sm truncate">{card.studentName}</p>
          {card.phone && (
            <p className="text-xs text-muted-foreground">{card.phone}</p>
          )}
        </div>

        {/* Row 2: Badges */}
        <div className="flex items-center gap-1.5 flex-wrap">
          <Badge variant="outline" className="text-xs">{card.year}</Badge>
          <Badge className="text-xs bg-purple-100 text-purple-700 hover:bg-purple-100">
            {card.serviceType}
          </Badge>
          <span className="text-sm">{countryFlag(card.country)}</span>
          {card.countryMissing && (
            <Badge variant="destructive" className="text-xs">?</Badge>
          )}
          <span className="text-xs font-medium ml-auto">{card.amount}&euro;</span>
        </div>

        {/* Row 3: Notes */}
        {card.pipelineNotes && (
          <p className="text-xs text-muted-foreground line-clamp-2">{card.pipelineNotes}</p>
        )}

        {/* Row 4: Document tags + counter */}
        <DocumentTags
          checklist={card.documentChecklist}
          complete={card.documentsComplete}
          total={card.documentsTotal}
        />

        {/* Row 5: Actions */}
        <div className="flex items-center gap-2 pt-1">
          {card.canRetreat && (
            <Button
              variant="ghost"
              size="sm"
              className="min-h-[44px] flex-1"
              disabled={busy}
              onClick={retreat}
            >
              &larr;
            </Button>
          )}
          {card.canAdvance && (
            <Button
              size="sm"
              className="min-h-[44px] flex-1 bg-green-600 hover:bg-green-700"
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
