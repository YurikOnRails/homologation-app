import { Link, usePage } from "@inertiajs/react"
import { useTranslation } from "react-i18next"
import { FileText, Clock, CreditCard, CheckCircle, Plus } from "lucide-react"
import { AuthenticatedLayout } from "@/components/layout/AuthenticatedLayout"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { routes } from "@/lib/routes"
import type { SharedProps } from "@/types/index"
import type {
  DashboardIndexProps,
  DashboardStudentStats,
  DashboardAdminStats,
} from "@/types/pages"

export default function DashboardIndex() {
  const { t } = useTranslation()
  const { stats, features } = usePage<SharedProps & DashboardIndexProps>().props

  return (
    <AuthenticatedLayout>
      <div className="space-y-6">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <h1 className="text-2xl font-bold">{t("nav.dashboard")}</h1>
          {features.canCreateRequest && (
            <Link href={routes.newRequest}>
              <Button className="w-full sm:w-auto min-h-[44px]">
                <Plus className="mr-2 h-4 w-4" />
                {t("requests.new_request")}
              </Button>
            </Link>
          )}
        </div>

        {features.canCreateRequest ? (
          <StudentStats stats={stats as DashboardStudentStats} />
        ) : (
          <AdminStats stats={stats as DashboardAdminStats} />
        )}
      </div>
    </AuthenticatedLayout>
  )
}

function StudentStats({ stats }: { stats: DashboardStudentStats }) {
  const { t } = useTranslation()
  return (
    <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
      <StatCard
        icon={<FileText className="h-5 w-5" />}
        label={t("requests.title")}
        value={stats.myRequests}
        href={routes.requests}
      />
      <StatCard
        icon={<Clock className="h-5 w-5" />}
        label={t("admin.stats.open_requests")}
        value={stats.pendingRequests}
        href={routes.requests}
      />
    </div>
  )
}

function AdminStats({ stats }: { stats: DashboardAdminStats }) {
  const { t } = useTranslation()
  return (
    <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
      <StatCard
        icon={<FileText className="h-5 w-5" />}
        label={t("admin.stats.total_requests")}
        value={stats.totalRequests}
        href={routes.requests}
      />
      <StatCard
        icon={<Clock className="h-5 w-5" />}
        label={t("admin.stats.open_requests")}
        value={stats.openRequests}
        href={routes.requests}
      />
      <StatCard
        icon={<CreditCard className="h-5 w-5" />}
        label={t("admin.stats.awaiting_payment")}
        value={stats.awaitingPayment}
        href={routes.requests}
      />
      <StatCard
        icon={<CheckCircle className="h-5 w-5" />}
        label={t("admin.stats.resolved")}
        value={stats.resolved}
        href={routes.requests}
      />
    </div>
  )
}

function StatCard({
  icon,
  label,
  value,
  href,
}: {
  icon: React.ReactNode
  label: string
  value: number
  href: string
}) {
  return (
    <Link href={href}>
      <Card className="hover:bg-muted/50 cursor-pointer transition-colors">
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">{label}</CardTitle>
          <span className="text-muted-foreground">{icon}</span>
        </CardHeader>
        <CardContent>
          <div className="text-3xl font-bold">{value}</div>
        </CardContent>
      </Card>
    </Link>
  )
}
