import { useTranslation } from "react-i18next"
import { Card, CardContent } from "@/components/ui/card"
import { formatCurrency } from "@/lib/utils"
import type { PipelineStats } from "@/types/pages"

interface StatsBarProps {
  stats: PipelineStats
}

export function StatsBar({ stats }: StatsBarProps) {
  const { t } = useTranslation()

  // Show at most 2 most recent years to keep the grid stable at 5 columns
  const yearEntries = Object.entries(stats.byYear)
    .sort(([a], [b]) => Number(b) - Number(a))
    .slice(0, 2)

  return (
    <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-4">
      <StatCard label={t("pipeline.stats.active")} value={stats.active} />
      <StatCard
        label={t("pipeline.stats.revenue")}
        value={formatCurrency(stats.revenue)}
        className="text-green-600"
      />
      {yearEntries.map(([year, count]) => (
        <StatCard key={year} label={year} value={count} />
      ))}
      {yearEntries.length < 2 && (
        <StatCard label={t("pipeline.stats.no_payment")} value={stats.noPago} />
      )}
      <StatCard label={t("pipeline.stats.cotejo")} value={stats.cotejo} />
    </div>
  )
}

function StatCard({
  label,
  value,
  className,
}: {
  label: string
  value: string | number
  className?: string
}) {
  return (
    <Card>
      <CardContent className="p-4">
        <p className="text-xs text-muted-foreground">{label}</p>
        <p className={`text-2xl font-bold ${className ?? ""}`}>{value}</p>
      </CardContent>
    </Card>
  )
}
