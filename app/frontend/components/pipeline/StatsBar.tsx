import { useTranslation } from "react-i18next"
import { Separator } from "@/components/ui/separator"
import { formatCurrency } from "@/lib/utils"
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
    <div className="flex items-center gap-0 overflow-x-auto rounded-lg border bg-card">
      <StatCell label={t("pipeline.stats.active")} value={stats.active} />
      <Separator orientation="vertical" className="h-10" />
      <StatCell
        label={t("pipeline.stats.revenue")}
        value={formatCurrency(stats.revenue)}
        className="text-green-600"
      />
      {yearEntries.map(([year, count]) => (
        <span key={year}>
          <Separator orientation="vertical" className="h-10" />
          <StatCell label={year} value={count} />
        </span>
      ))}
      <Separator orientation="vertical" className="h-10" />
      <StatCell label={t("pipeline.stats.no_payment")} value={stats.noPago} />
      <Separator orientation="vertical" className="h-10" />
      <StatCell label={t("pipeline.stats.cotejo")} value={stats.cotejo} />
    </div>
  )
}

function StatCell({
  label,
  value,
  className,
}: {
  label: string
  value: string | number
  className?: string
}) {
  return (
    <div className="flex-1 min-w-[100px] px-4 py-3 text-center">
      <p className="text-[11px] text-muted-foreground uppercase tracking-wide">{label}</p>
      <p className={`text-xl font-bold tabular-nums ${className ?? ""}`}>{value}</p>
    </div>
  )
}
