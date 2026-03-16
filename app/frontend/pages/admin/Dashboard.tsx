import { usePage, Link, router } from "@inertiajs/react"
import { useTranslation } from "react-i18next"
import {
  FileText,
  FolderOpen,
  CreditCard,
  CheckCircle,
  Users,
  GraduationCap,
  AlertCircle,
} from "lucide-react"
import { AuthenticatedLayout } from "@/components/layout/AuthenticatedLayout"
import { StatsCard } from "@/components/admin/StatsCard"
import { RequestsByMonthChart, RequestsByStatusChart } from "@/components/admin/Charts"
import { StatusBadge } from "@/components/common/StatusBadge"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { routes } from "@/lib/routes"
import type { SharedProps } from "@/types"
import type { AdminDashboardProps, RequestListItem } from "@/types/pages"

export default function AdminDashboard() {
  const { t } = useTranslation()
  const { stats, requestsByMonth, requestsByStatus, recentRequests, failedSyncs } =
    usePage<SharedProps & AdminDashboardProps>().props

  return (
    <AuthenticatedLayout>
      <div className="space-y-6">
        <h1 className="text-2xl font-bold">{t("admin.dashboard")}</h1>

        {/* Stats grid */}
        <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-6">
          <StatsCard
            icon={<FileText className="h-5 w-5" />}
            label={t("admin.stats.total_requests")}
            value={stats.totalRequests}
          />
          <StatsCard
            icon={<FolderOpen className="h-5 w-5" />}
            label={t("admin.stats.open_requests")}
            value={stats.openRequests}
          />
          <StatsCard
            icon={<CreditCard className="h-5 w-5" />}
            label={t("admin.stats.awaiting_payment")}
            value={stats.awaitingPayment}
          />
          <StatsCard
            icon={<CheckCircle className="h-5 w-5" />}
            label={t("admin.stats.resolved")}
            value={stats.resolved}
          />
          <StatsCard
            icon={<Users className="h-5 w-5" />}
            label={t("admin.stats.total_users")}
            value={stats.totalUsers}
          />
          <StatsCard
            icon={<GraduationCap className="h-5 w-5" />}
            label={t("admin.stats.total_teachers")}
            value={stats.totalTeachers}
          />
        </div>

        {/* Failed syncs alert */}
        {failedSyncs > 0 && (
          <div className="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 p-3 text-sm text-red-700">
            <AlertCircle className="h-4 w-4 shrink-0" />
            <span>
              {t("admin.failed_syncs", { count: failedSyncs })}{" "}
              <Link href={routes.requests} className="underline font-medium">
                {t("admin.view_failed_syncs")}
              </Link>
            </span>
          </div>
        )}

        {/* Charts */}
        <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
          <RequestsByMonthChart data={requestsByMonth} />
          <RequestsByStatusChart data={requestsByStatus} />
        </div>

        {/* Recent requests */}
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">{t("admin.recent_requests")}</CardTitle>
          </CardHeader>
          <CardContent className="p-0">
            {/* Desktop table */}
            <div className="hidden md:block overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b bg-muted/30">
                    <th className="p-3 text-left font-medium">{t("requests.table.subject")}</th>
                    <th className="p-3 text-left font-medium">{t("requests.table.student")}</th>
                    <th className="p-3 text-left font-medium">{t("requests.table.status")}</th>
                    <th className="p-3 text-left font-medium">{t("requests.table.created")}</th>
                  </tr>
                </thead>
                <tbody>
                  {recentRequests.map((r) => (
                    <RecentRequestRow key={r.id} request={r} />
                  ))}
                </tbody>
              </table>
            </div>
            {/* Mobile cards */}
            <div className="md:hidden divide-y">
              {recentRequests.map((r) => (
                <RecentRequestCard key={r.id} request={r} />
              ))}
            </div>
            {recentRequests.length === 0 && (
              <p className="p-4 text-center text-sm text-muted-foreground">{t("requests.no_requests")}</p>
            )}
          </CardContent>
        </Card>
      </div>
    </AuthenticatedLayout>
  )
}

function RecentRequestRow({ request }: { request: RequestListItem }) {
  const { i18n } = useTranslation()
  return (
    <tr className="border-b hover:bg-muted/30 cursor-pointer" onClick={() => router.visit(routes.request(request.id))}>
      <td className="p-3">{request.subject}</td>
      <td className="p-3 text-muted-foreground">{request.user.name}</td>
      <td className="p-3">
        <StatusBadge status={request.status} />
      </td>
      <td className="p-3 text-muted-foreground">
        {new Date(request.createdAt).toLocaleDateString(i18n.language)}
      </td>
    </tr>
  )
}

function RecentRequestCard({ request }: { request: RequestListItem }) {
  const { i18n } = useTranslation()
  return (
    <div className="p-3">
      <div className="flex items-start justify-between gap-2">
        <div className="min-w-0">
          <p className="font-medium text-sm truncate">{request.subject}</p>
          <p className="text-xs text-muted-foreground">{request.user.name}</p>
        </div>
        <StatusBadge status={request.status} />
      </div>
      <p className="mt-1 text-xs text-muted-foreground">
        {new Date(request.createdAt).toLocaleDateString(i18n.language)}
      </p>
    </div>
  )
}
