import { useState } from "react"
import { useTranslation } from "react-i18next"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { LessonCard } from "./LessonCard"
import type { LessonItem } from "@/types/pages"

interface DayViewProps {
  lessons: LessonItem[]
  onLessonClick: (lesson: LessonItem) => void
}

export function DayView({ lessons, onLessonClick }: DayViewProps) {
  const { t } = useTranslation()
  const [selectedDate, setSelectedDate] = useState(new Date().toISOString().slice(0, 10))

  const dayLessons = lessons.filter((l) => {
    return new Date(l.scheduledAt).toDateString() === new Date(selectedDate).toDateString()
  })

  return (
    <div className="lg:hidden space-y-4">
      <div className="space-y-1">
        <Label>{t("lessons.date")}</Label>
        <Input
          type="date"
          value={selectedDate}
          onChange={(e) => setSelectedDate(e.target.value)}
          className="max-w-xs"
        />
      </div>

      {dayLessons.length === 0 ? (
        <p className="text-sm text-muted-foreground">{t("lessons.no_lessons")}</p>
      ) : (
        <div className="space-y-2">
          {dayLessons
            .sort((a, b) => new Date(a.scheduledAt).getTime() - new Date(b.scheduledAt).getTime())
            .map((lesson) => (
              <div key={lesson.id} className="p-3 border rounded-lg min-h-[44px]">
                <LessonCard lesson={lesson} onClick={onLessonClick} />
              </div>
            ))}
        </div>
      )}
    </div>
  )
}
