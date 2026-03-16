import { useState } from "react"
import { usePage, router } from "@inertiajs/react"
import { useTranslation } from "react-i18next"
import { Badge } from "@/components/ui/badge"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { Button } from "@/components/ui/button"
import { routes } from "@/lib/routes"
import type { SharedProps } from "@/types"
import type { AdminLessonsProps, LessonItem } from "@/types/pages"

const STATUS_COLORS: Record<string, string> = {
  scheduled: "bg-blue-100 text-blue-700",
  completed: "bg-gray-100 text-gray-600",
  cancelled: "bg-red-50 text-red-600",
}

function LessonRow({ lesson }: { lesson: LessonItem }) {
  const { t, i18n } = useTranslation()
  const date = new Date(lesson.scheduledAt)

  return (
    <tr className="border-b hover:bg-muted/30">
      <td className="p-3 text-sm">
        {date.toLocaleDateString(i18n.language, { month: "short", day: "numeric", hour: "2-digit", minute: "2-digit" })}
      </td>
      <td className="p-3 text-sm">{lesson.teacherName}</td>
      <td className="p-3 text-sm">{lesson.studentName}</td>
      <td className="p-3 text-sm">{t("lessons.duration_minutes", { minutes: lesson.durationMinutes })}</td>
      <td className="p-3">
        <Badge variant="secondary" className={STATUS_COLORS[lesson.status] ?? ""}>
          {t(`lessons.status.${lesson.status}`)}
        </Badge>
      </td>
      <td className="p-3 text-sm">
        {lesson.meetingLinkReady ? (
          <span className="text-green-600">{t("calendar.link_ready")}</span>
        ) : (
          <span className="text-yellow-600">{t("calendar.link_needed")}</span>
        )}
      </td>
    </tr>
  )
}

function LessonCard({ lesson }: { lesson: LessonItem }) {
  const { t, i18n } = useTranslation()
  const date = new Date(lesson.scheduledAt)

  return (
    <div className="border rounded-lg p-4 space-y-2 min-h-[44px]">
      <div className="flex items-start justify-between gap-2">
        <div className="text-sm font-medium">
          {date.toLocaleDateString(i18n.language, { weekday: "short", month: "short", day: "numeric", hour: "2-digit", minute: "2-digit" })}
        </div>
        <Badge variant="secondary" className={STATUS_COLORS[lesson.status] ?? ""}>
          {t(`lessons.status.${lesson.status}`)}
        </Badge>
      </div>
      <div className="text-sm text-muted-foreground">
        {t("lessons.teacher")}: {lesson.teacherName} · {t("lessons.student")}: {lesson.studentName}
      </div>
      <div className="text-sm text-muted-foreground">
        {t("lessons.duration_minutes", { minutes: lesson.durationMinutes })} ·{" "}
        {lesson.meetingLinkReady ? (
          <span className="text-green-600">{t("calendar.link_ready")}</span>
        ) : (
          <span className="text-yellow-600">{t("calendar.link_needed")}</span>
        )}
      </div>
    </div>
  )
}

export default function AdminLessons() {
  const { t } = useTranslation()
  const { lessons, teachers, students } = usePage<SharedProps & AdminLessonsProps>().props

  const [teacherFilter, setTeacherFilter] = useState("")
  const [studentFilter, setStudentFilter] = useState("")
  const [statusFilter, setStatusFilter] = useState("")

  function applyFilters() {
    const params: Record<string, string> = {}
    if (teacherFilter) params.teacher_id = teacherFilter
    if (studentFilter) params.student_id = studentFilter
    if (statusFilter) params.status = statusFilter
    router.get(routes.admin.lessons, params, { preserveState: true })
  }

  function clearFilters() {
    setTeacherFilter("")
    setStudentFilter("")
    setStatusFilter("")
    router.get(routes.admin.lessons, {}, { preserveState: true })
  }

  return (
    <div className="space-y-4">
      <h1 className="text-xl font-bold">{t("nav.all_lessons")}</h1>

      {/* Filters */}
      <div className="flex flex-wrap gap-2 items-end">
        <Select value={teacherFilter} onValueChange={setTeacherFilter}>
          <SelectTrigger className="w-40 min-h-[44px]">
            <SelectValue placeholder={t("lessons.teacher")} />
          </SelectTrigger>
          <SelectContent>
            {teachers.map((u) => (
              <SelectItem key={u.id} value={String(u.id)}>{u.name}</SelectItem>
            ))}
          </SelectContent>
        </Select>

        <Select value={studentFilter} onValueChange={setStudentFilter}>
          <SelectTrigger className="w-40 min-h-[44px]">
            <SelectValue placeholder={t("lessons.student")} />
          </SelectTrigger>
          <SelectContent>
            {students.map((u) => (
              <SelectItem key={u.id} value={String(u.id)}>{u.name}</SelectItem>
            ))}
          </SelectContent>
        </Select>

        <Select value={statusFilter} onValueChange={setStatusFilter}>
          <SelectTrigger className="w-36 min-h-[44px]">
            <SelectValue placeholder={t("lessons.status_label")} />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="scheduled">{t("lessons.status.scheduled")}</SelectItem>
            <SelectItem value="completed">{t("lessons.status.completed")}</SelectItem>
            <SelectItem value="cancelled">{t("lessons.status.cancelled")}</SelectItem>
          </SelectContent>
        </Select>

        <Button onClick={applyFilters} size="sm" className="min-h-[44px]">{t("common.filter")}</Button>
        <Button onClick={clearFilters} variant="ghost" size="sm" className="min-h-[44px]">{t("common.clear")}</Button>
      </div>

      {lessons.length === 0 ? (
        <p className="text-sm text-muted-foreground py-8 text-center">{t("lessons.no_lessons")}</p>
      ) : (
        <>
          {/* Desktop table */}
          <div className="hidden md:block border rounded-lg overflow-hidden">
            <table className="w-full text-sm">
              <thead className="bg-muted/30">
                <tr>
                  <th className="text-left p-3 font-medium">{t("lessons.date")}</th>
                  <th className="text-left p-3 font-medium">{t("lessons.teacher")}</th>
                  <th className="text-left p-3 font-medium">{t("lessons.student")}</th>
                  <th className="text-left p-3 font-medium">{t("lessons.duration")}</th>
                  <th className="text-left p-3 font-medium">{t("lessons.status.scheduled")}</th>
                  <th className="text-left p-3 font-medium">{t("lessons.meeting_link")}</th>
                </tr>
              </thead>
              <tbody>
                {lessons.map((l) => <LessonRow key={l.id} lesson={l} />)}
              </tbody>
            </table>
          </div>

          {/* Mobile cards */}
          <div className="md:hidden space-y-3">
            {lessons.map((l) => <LessonCard key={l.id} lesson={l} />)}
          </div>
        </>
      )}
    </div>
  )
}
