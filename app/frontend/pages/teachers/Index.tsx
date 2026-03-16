import { usePage } from "@inertiajs/react"
import { useTranslation } from "react-i18next"
import { AuthenticatedLayout } from "@/components/layout/AuthenticatedLayout"
import { TeacherCard } from "@/components/teachers/TeacherCard"
import type { SharedProps } from "@/types/index"
import type { TeachersIndexProps } from "@/types/pages"

export default function TeachersIndex() {
  const { t } = useTranslation()
  const { teachers, availableStudents } = usePage<SharedProps & TeachersIndexProps>().props

  return (
    <AuthenticatedLayout>
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-bold">{t("teachers.title")}</h1>
      </div>

      {teachers.length === 0 ? (
        <p className="text-center text-sm text-muted-foreground py-8">{t("common.no_results")}</p>
      ) : (
        <div className="grid gap-4 sm:grid-cols-1 lg:grid-cols-2">
          {teachers.map((teacher) => (
            <TeacherCard
              key={teacher.id}
              teacher={teacher}
              availableStudents={availableStudents}
            />
          ))}
        </div>
      )}
    </div>
    </AuthenticatedLayout>
  )
}
