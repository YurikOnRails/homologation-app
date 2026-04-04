import { useTranslation } from "react-i18next"
import { cn, formatCurrency } from "@/lib/utils"
import type { PipelineStats } from "@/types/pages"

interface StatsBarProps {
  stats: PipelineStats
}

export function StatsBar({ stats }: StatsBarProps) {
  const { t } = useTranslation()

  const yearEntries = Object.entries(stats.byYear)
    .sort(([a], [b]) => Number(b) - Number(a))
    .slice(0, 2)

  return (
    <div className="grid grid-cols-3 sm:grid-cols-6 gap-px rounded-lg border bg-border overflow-hidden">
      <StatCell
        label={t("pipeline.stats.active")}
        value={stats.active}
      />
      <StatCell
        label={t("pipeline.stats.revenue")}
        value={formatCurrency(stats.revenue)}
      />
      {yearEntries.map(([year, count]) => (
        <StatCell
          key={year}
          label={year}
          value={count}
        />
      ))}
      <StatCell
        label={t("pipeline.stats.no_payment")}
        value={stats.noPago}
        accent={stats.noPago > 0 ? "text-destructive" : undefined}
      />
      <StatCell
        label={t("pipeline.stats.cotejo")}
        value={stats.cotejo}
        sub={`${stats.cotejoMinisterio ?? 0}🏛 ${stats.cotejoDelegacion ?? 0}🏢`}
      />
    </div>
  )
}

function StatCell({
  label,
  value,
  accent,
  sub,
}: {
  label: string
  value: string | number
  accent?: string
  sub?: string
}) {
  return (
    <div className="bg-card px-3 py-2.5 text-center">
      <p className="text-[11px] uppercase tracking-wide leading-tight text-muted-foreground">
        {label}
      </p>
      <p className={cn("text-lg font-bold tabular-nums leading-tight mt-0.5 text-foreground", accent)}>
        {value}
      </p>
      {sub && (
        <p className="text-[10px] text-muted-foreground tabular-nums mt-0.5">{sub}</p>
      )}
    </div>
  )
}
