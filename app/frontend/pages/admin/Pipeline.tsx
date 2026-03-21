import { useState, useMemo } from "react"
import { usePage } from "@inertiajs/react"
import { useTranslation } from "react-i18next"
import { Kanban } from "lucide-react"
import { AuthenticatedLayout } from "@/components/layout/AuthenticatedLayout"
import { Main } from "@/components/layout/Main"
import { StatsBar } from "@/components/pipeline/StatsBar"
import { FilterBar } from "@/components/pipeline/FilterBar"
import { KanbanBoard } from "@/components/pipeline/KanbanBoard"
import { HorizontalGroup } from "@/components/pipeline/HorizontalGroup"
import { CardEditDialog } from "@/components/pipeline/CardEditDialog"
import { PipelineCard as PipelineCardComponent } from "@/components/pipeline/PipelineCard"
import { ALL_STAGES, HORIZONTAL_STAGES } from "@/components/pipeline/constants"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { routes } from "@/lib/routes"
import type { SharedProps } from "@/types"
import type { PipelineIndexProps, PipelineCard } from "@/types/pages"

export default function Pipeline() {
  const { t } = useTranslation()
  const { stages, stats, filters } = usePage<SharedProps & PipelineIndexProps>().props

  const [editCard, setEditCard] = useState<PipelineCard | null>(null)
  const [mobileStage, setMobileStage] = useState<string>("pago_recibido")

  const isEmpty = useMemo(
    () => Object.values(stages).every((cards) => cards.length === 0),
    [stages]
  )

  return (
    <AuthenticatedLayout
      breadcrumbs={[
        { label: t("nav.admin"), href: routes.admin.root },
        { label: t("pipeline.title") },
      ]}
    >
      <Main>
        <div className="space-y-6">
          {/* Title */}
          <h1 className="text-2xl font-bold tracking-tight">{t("pipeline.title")}</h1>

          {/* Stats */}
          <StatsBar stats={stats} />

          {/* Filters */}
          <FilterBar filters={filters} />

          {isEmpty ? (
            /* Empty state */
            <div className="flex flex-col items-center justify-center py-16 text-center">
              <div className="rounded-full bg-muted p-4 mb-4">
                <Kanban className="h-8 w-8 text-muted-foreground" />
              </div>
              <h2 className="text-lg font-semibold mb-1">{t("pipeline.empty_title")}</h2>
              <p className="text-sm text-muted-foreground">{t("pipeline.empty_hint")}</p>
            </div>
          ) : (
            <>
              {/* Mobile: stage tabs + vertical list */}
              <div className="md:hidden">
                <div className="flex gap-2 overflow-x-auto pb-2">
                  {ALL_STAGES.map((stage) => (
                    <Button
                      key={stage}
                      variant={mobileStage === stage ? "default" : "outline"}
                      size="sm"
                      className="min-h-[44px] whitespace-nowrap flex-shrink-0"
                      onClick={() => setMobileStage(stage)}
                    >
                      {t(`pipeline.stages.${stage}`)}{" "}
                      <Badge variant="secondary" className="ml-1">
                        {(stages[stage] ?? []).length}
                      </Badge>
                    </Button>
                  ))}
                </div>
                <div className="space-y-3 mt-3">
                  {(stages[mobileStage] ?? []).map((card) => (
                    <PipelineCardComponent
                      key={card.id}
                      card={card}
                      onEdit={setEditCard}
                    />
                  ))}
                  {(stages[mobileStage] ?? []).length === 0 && (
                    <p className="text-sm text-muted-foreground py-4 text-center">
                      {t("pipeline.no_cards")}
                    </p>
                  )}
                </div>
              </div>

              {/* Desktop: full kanban + horizontal groups */}
              <div className="hidden md:block space-y-6">
                <KanbanBoard stages={stages} onEditCard={setEditCard} />
                {HORIZONTAL_STAGES.map(({ stage, icon }) => (
                  <HorizontalGroup
                    key={stage}
                    stage={stage}
                    cards={stages[stage] ?? []}
                    icon={icon}
                    onEditCard={setEditCard}
                  />
                ))}
              </div>
            </>
          )}
        </div>

        {/* Edit dialog */}
        <CardEditDialog
          card={editCard}
          open={editCard !== null}
          onClose={() => setEditCard(null)}
        />
      </Main>
    </AuthenticatedLayout>
  )
}
