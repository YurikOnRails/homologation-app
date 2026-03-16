import { useTranslation } from "react-i18next"
import {
  ResponsiveContainer,
  LineChart,
  Line,
  XAxis,
  YAxis,
  Tooltip,
  BarChart,
  Bar,
  Cell,
} from "recharts"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"

interface RequestsByMonthChartProps {
  data: Record<string, number>
}

export function RequestsByMonthChart({ data }: RequestsByMonthChartProps) {
  const { t } = useTranslation()
  const chartData = Object.entries(data)
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([month, count]) => ({ month, count }))

  return (
    <Card>
      <CardHeader className="pb-2">
        <CardTitle className="text-sm font-medium">{t("admin.charts.requests_over_time")}</CardTitle>
      </CardHeader>
      <CardContent>
        <ResponsiveContainer width="100%" height={200}>
          <LineChart data={chartData}>
            <XAxis dataKey="month" tick={{ fontSize: 11 }} />
            <YAxis tick={{ fontSize: 11 }} />
            <Tooltip />
            <Line type="monotone" dataKey="count" stroke="hsl(var(--primary))" strokeWidth={2} dot={false} />
          </LineChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  )
}

const STATUS_COLORS: Record<string, string> = {
  draft: "#94a3b8",
  submitted: "#60a5fa",
  in_review: "#fbbf24",
  awaiting_reply: "#fb923c",
  awaiting_payment: "#a78bfa",
  payment_confirmed: "#34d399",
  in_progress: "#38bdf8",
  resolved: "#4ade80",
  closed: "#9ca3af",
}

interface RequestsByStatusChartProps {
  data: Record<string, number>
}

export function RequestsByStatusChart({ data }: RequestsByStatusChartProps) {
  const { t } = useTranslation()
  const chartData = Object.entries(data).map(([status, count]) => ({
    status: t(`requests.status.${status}`),
    count,
    color: STATUS_COLORS[status] ?? "#94a3b8",
  }))

  return (
    <Card>
      <CardHeader className="pb-2">
        <CardTitle className="text-sm font-medium">{t("admin.charts.by_status")}</CardTitle>
      </CardHeader>
      <CardContent>
        <ResponsiveContainer width="100%" height={200}>
          <BarChart data={chartData}>
            <XAxis dataKey="status" tick={{ fontSize: 10 }} />
            <YAxis tick={{ fontSize: 11 }} />
            <Tooltip />
            <Bar dataKey="count">
              {chartData.map((entry, index) => (
                <Cell key={index} fill={entry.color} />
              ))}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  )
}
