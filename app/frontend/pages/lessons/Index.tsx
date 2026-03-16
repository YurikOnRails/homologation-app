import { usePage } from "@inertiajs/react"
import { useTranslation } from "react-i18next"
import { LessonList } from "@/components/lessons/LessonList"
import type { SharedProps } from "@/types"
import type { LessonsIndexProps } from "@/types/pages"

export default function LessonsIndex() {
  const { t } = useTranslation()
  const { upcoming, past } = usePage<SharedProps & LessonsIndexProps>().props

  return (
    <div className="space-y-4">
      <h1 className="text-xl font-bold">{t("lessons.title")}</h1>
      <LessonList upcoming={upcoming} past={past} />
    </div>
  )
}
