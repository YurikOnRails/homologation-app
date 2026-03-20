import { useState } from "react"
import { router } from "@inertiajs/react"
import { useTranslation } from "react-i18next"
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { routes } from "@/lib/routes"

interface AssignStudentDialogProps {
  teacherId: number
  teacherName: string
  availableStudents: Array<{ id: number; name: string }>
  trigger: React.ReactNode
}

export function AssignStudentDialog({ teacherId, teacherName, availableStudents, trigger }: AssignStudentDialogProps) {
  const { t } = useTranslation()
  const [open, setOpen] = useState(false)
  const [search, setSearch] = useState("")
  const [selectedId, setSelectedId] = useState<number | null>(null)

  const filtered = availableStudents.filter((s) =>
    s.name.toLowerCase().includes(search.toLowerCase()),
  )

  const handleAssign = () => {
    if (!selectedId) return
    router.post(
      routes.assignStudent(teacherId),
      { student_id: selectedId },
      {
        onSuccess: () => {
          setOpen(false)
          setSelectedId(null)
          setSearch("")
        },
      },
    )
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>{trigger}</DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>
            {t("teachers.assign_student")} — {teacherName}
          </DialogTitle>
        </DialogHeader>
        <Input
          placeholder={t("teachers.search_student")}
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="text-sm"
        />
        <div className="max-h-60 overflow-y-auto space-y-1">
          <p className="text-xs text-muted-foreground px-1">{t("teachers.available_students")}</p>
          {filtered.length === 0 ? (
            <p className="text-sm text-muted-foreground py-4 text-center">{t("common.no_results")}</p>
          ) : (
            filtered.map((student) => (
              <button
                key={student.id}
                type="button"
                onClick={() => setSelectedId(student.id === selectedId ? null : student.id)}
                className={`w-full text-left px-3 py-2 rounded text-sm transition-colors hover:bg-accent ${
                  selectedId === student.id ? "bg-accent font-medium" : ""
                }`}
              >
                {student.name}
              </button>
            ))
          )}
        </div>
        <div className="flex justify-end gap-2">
          <Button variant="outline" onClick={() => setOpen(false)}>
            {t("common.cancel")}
          </Button>
          <Button onClick={handleAssign} disabled={!selectedId}>
            {t("teachers.assign_student")}
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  )
}
