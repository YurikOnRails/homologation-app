import { useState } from "react"
import { Link, router, usePage } from "@inertiajs/react"
import { useTranslation } from "react-i18next"
import { Plus } from "lucide-react"
import { AuthenticatedLayout } from "@/components/layout/AuthenticatedLayout"
import { StatusBadge } from "@/components/common/StatusBadge"
import { FormattedDate } from "@/components/common/FormattedDate"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import { Card, CardContent } from "@/components/ui/card"
import { routes } from "@/lib/routes"
import type { SharedProps } from "@/types/index"
import type { RequestsIndexProps, RequestListItem } from "@/types/pages"

const STATUSES = [
  "draft", "submitted", "in_review", "awaiting_reply",
  "awaiting_payment", "payment_confirmed", "in_progress", "resolved", "closed",
]

export default function RequestsIndex() {
  const { t } = useTranslation()
  const { requests, features } = usePage<SharedProps & RequestsIndexProps>().props

  const [search, setSearch] = useState("")
  const [statusFilter, setStatusFilter] = useState("all")

  const filtered = requests.filter((r) => {
    const matchSearch = r.subject.toLowerCase().includes(search.toLowerCase())
    const matchStatus = statusFilter === "all" || r.status === statusFilter
    return matchSearch && matchStatus
  })

  return (
    <AuthenticatedLayout>
      <div className="space-y-4">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <h1 className="text-2xl font-bold">{t("requests.title")}</h1>
          {features.canCreateRequest && (
            <Link href={routes.newRequest}>
              <Button className="w-full sm:w-auto min-h-[44px]">
                <Plus className="mr-2 h-4 w-4" />
                {t("requests.new_request")}
              </Button>
            </Link>
          )}
        </div>

        {/* Filters */}
        <div className="flex flex-col gap-2 sm:flex-row">
          <Input
            placeholder={t("common.search")}
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="sm:max-w-xs"
          />
          <Select value={statusFilter} onValueChange={setStatusFilter}>
            <SelectTrigger className="sm:w-48">
              <SelectValue placeholder={t("requests.table.status_filter")} />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">{t("common.filter")}</SelectItem>
              {STATUSES.map((s) => (
                <SelectItem key={s} value={s}>
                  {t(`requests.status.${s}`)}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        {filtered.length === 0 ? (
          <p className="text-muted-foreground py-8 text-center">
            {t("requests.no_requests")}
          </p>
        ) : (
          <>
            {/* Desktop table */}
            <div className="hidden md:block rounded-md border">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>{t("requests.table.subject")}</TableHead>
                    <TableHead className="w-16">{t("requests.table.id")}</TableHead>
                    <TableHead>{t("requests.table.created")}</TableHead>
                    <TableHead>{t("requests.table.last_activity")}</TableHead>
                    <TableHead>{t("requests.table.status")}</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filtered.map((r) => (
                    <TableRow
                      key={r.id}
                      className="cursor-pointer hover:bg-muted/50"
                      onClick={() => router.visit(routes.request(r.id))}
                    >
                      <TableCell className="font-medium">{r.subject}</TableCell>
                      <TableCell className="text-muted-foreground">#{r.id}</TableCell>
                      <TableCell><FormattedDate date={r.createdAt} /></TableCell>
                      <TableCell><FormattedDate date={r.updatedAt} /></TableCell>
                      <TableCell><StatusBadge status={r.status} /></TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>

            {/* Mobile card list */}
            <div className="md:hidden space-y-2">
              {filtered.map((r) => (
                <RequestCard key={r.id} request={r} />
              ))}
            </div>
          </>
        )}
      </div>
    </AuthenticatedLayout>
  )
}

function RequestCard({ request }: { request: RequestListItem }) {
  const { t } = useTranslation()
  return (
    <Card
      className="cursor-pointer hover:bg-muted/50"
      onClick={() => router.visit(routes.request(request.id))}
    >
      <CardContent className="p-4 space-y-2">
        <div className="flex items-start justify-between gap-2">
          <p className="font-medium leading-tight">{request.subject}</p>
          <StatusBadge status={request.status} />
        </div>
        <div className="flex gap-4 text-xs text-muted-foreground">
          <span>#{request.id}</span>
          <span>
            {t("requests.table.last_activity")}:{" "}
            <FormattedDate date={request.updatedAt} />
          </span>
        </div>
      </CardContent>
    </Card>
  )
}
