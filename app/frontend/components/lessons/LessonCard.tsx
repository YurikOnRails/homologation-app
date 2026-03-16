import { useTranslation } from "react-i18next"
import { cn } from "@/lib/utils"
import type { LessonItem } from "@/types/pages"

interface LessonCardProps {
  lesson: LessonItem
  onClick?: (lesson: LessonItem) => void
}

function getLessonColor(lesson: LessonItem): string {
  if (lesson.status === "completed" || lesson.status === "cancelled") {
    return "bg-gray-100 border-gray-200 text-gray-500"
  }
  if (lesson.meetingLinkReady) {
    return "bg-green-50 border-green-200 text-green-800"
  }
  return "bg-yellow-50 border-yellow-200 text-yellow-800"
}

export function LessonCard({ lesson, onClick }: LessonCardProps) {
  const { t } = useTranslation()
  const time = new Date(lesson.scheduledAt).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })

  return (
    <div
      className={cn(
        "rounded border p-2 text-xs cursor-pointer hover:opacity-80 transition-opacity min-h-[44px]",
        getLessonColor(lesson),
        (lesson.status === "cancelled") && "line-through opacity-60"
      )}
      onClick={() => onClick?.(lesson)}
      role="button"
      tabIndex={0}
      onKeyDown={(e) => e.key === "Enter" && onClick?.(lesson)}
    >
      <div className="font-medium">{lesson.studentName}</div>
      <div className="opacity-75">{time} · {t("lessons.duration_minutes", { minutes: lesson.durationMinutes })}</div>
      {lesson.status === "completed" && (
        <div className="mt-0.5 opacity-60">{t("calendar.done")}</div>
      )}
    </div>
  )
}
