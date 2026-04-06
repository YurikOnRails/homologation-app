import { useTranslation } from "react-i18next"
import { cn, formatCurrency } from "@/lib/utils"
import type { FinanceData } from "@/types/pages"

interface FinanceSummaryProps {
  finance: FinanceData
}

export function FinanceSummary({ finance }: FinanceSummaryProps) {
  const { t } = useTranslation()

  const hasData = finance.totalRevenue > 0

  if (!hasData) {
    return (
      <div className="rounded-lg border bg-muted/50 p-4 text-center text-sm text-muted-foreground">
        {t("admin.finance.no_data")}
      </div>
    )
  }

  const yearEntries = Object.entries(finance.revenueByYear)
    .sort(([a], [b]) => Number(b) - Number(a))
    .slice(0, 3)

  return (
    <div className="grid grid-cols-3 sm:grid-cols-6 gap-px rounded-lg border bg-border overflow-hidden">
      <Cell
        label={t("admin.finance.homologation")}
        value={formatCurrency(finance.homologationRevenue)}
        sub={`${finance.homologationCount} ${t("admin.finance.paid_requests").toLowerCase()}`}
      />
      <Cell
        label={t("admin.finance.education")}
        value={formatCurrency(finance.educationRevenue)}
        sub={`${finance.educationLessons} ${t("admin.finance.lessons_completed").toLowerCase()}`}
      />
      <Cell
        label={t("admin.finance.total")}
        value={formatCurrency(finance.totalRevenue)}
        bold
      />
      <Cell
        label={t("admin.finance.average_deal")}
        value={formatCurrency(finance.averageDeal)}
      />
      {yearEntries.map(([year, amount]) => (
        <Cell
          key={year}
          label={year}
          value={formatCurrency(amount)}
        />
      ))}
    </div>
  )
}

function Cell({
  label,
  value,
  sub,
  bold,
}: {
  label: string
  value: string
  sub?: string
  bold?: boolean
}) {
  return (
    <div className="bg-card px-3 py-2.5 text-center">
      <p className="text-[11px] uppercase tracking-wide leading-tight text-muted-foreground">
        {label}
      </p>
      <p className={cn(
        "text-lg tabular-nums leading-tight mt-0.5 text-foreground",
        bold ? "font-extrabold" : "font-bold"
      )}>
        {value}
      </p>
      {sub && (
        <p className="text-[10px] text-muted-foreground tabular-nums mt-0.5">{sub}</p>
      )}
    </div>
  )
}
