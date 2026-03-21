import { useEffect } from "react"
import { useForm } from "@inertiajs/react"
import { useTranslation } from "react-i18next"
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Checkbox } from "@/components/ui/checkbox"
import { Button } from "@/components/ui/button"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { routes } from "@/lib/routes"
import { DOC_KEYS } from "@/components/pipeline/constants"
import type { PipelineCard } from "@/types/pages"

interface CardEditDialogProps {
  card: PipelineCard | null
  open: boolean
  onClose: () => void
}

const CURRENT_YEAR = new Date().getFullYear()
const YEARS = [CURRENT_YEAR - 1, CURRENT_YEAR, CURRENT_YEAR + 1]

export function CardEditDialog({ card, open, onClose }: CardEditDialogProps) {
  const { t } = useTranslation()
  const { data, setData, patch, processing, clearErrors } = useForm({
    pipeline_notes: "",
    payment_amount: 0,
    year: CURRENT_YEAR,
    document_checklist: {} as Record<string, boolean>,
  })

  useEffect(() => {
    if (card) {
      clearErrors()
      setData({
        pipeline_notes: card.pipelineNotes ?? "",
        payment_amount: card.amount,
        year: card.year,
        document_checklist: { ...card.documentChecklist },
      })
    }
  }, [card]) // eslint-disable-line react-hooks/exhaustive-deps -- setData/clearErrors are stable from useForm

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    if (!card) return
    patch(routes.admin.pipelineUpdate(card.id), {
      preserveScroll: true,
      onSuccess: () => onClose(),
    })
  }

  function toggleDoc(key: string) {
    setData("document_checklist", {
      ...data.document_checklist,
      [key]: !data.document_checklist[key],
    })
  }

  return (
    <Dialog open={open} onOpenChange={(v) => !v && onClose()}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>{t("pipeline.edit_dialog.title")}</DialogTitle>
          {card && (
            <p className="text-sm text-muted-foreground">{card.studentName}</p>
          )}
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Amount */}
          <div className="space-y-1.5">
            <Label>{t("pipeline.edit_dialog.amount")}</Label>
            <Input
              type="number"
              min={0}
              step={1}
              value={data.payment_amount}
              onChange={(e) => setData("payment_amount", Number(e.target.value))}
            />
          </div>

          {/* Year */}
          <div className="space-y-1.5">
            <Label>{t("pipeline.edit_dialog.year")}</Label>
            <Select
              value={String(data.year)}
              onValueChange={(v) => setData("year", Number(v))}
            >
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {YEARS.map((y) => (
                  <SelectItem key={y} value={String(y)}>{y}</SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {/* Notes */}
          <div className="space-y-1.5">
            <Label>{t("pipeline.edit_dialog.notes")}</Label>
            <Textarea
              value={data.pipeline_notes}
              onChange={(e) => setData("pipeline_notes", e.target.value)}
              rows={3}
            />
          </div>

          {/* Document checklist */}
          <div className="space-y-1.5">
            <Label>{t("pipeline.edit_dialog.documents")}</Label>
            <div className="grid grid-cols-2 gap-2">
              {DOC_KEYS.map((key) => (
                <label
                  key={key}
                  className="flex items-center gap-2 cursor-pointer min-h-[44px]"
                >
                  <Checkbox
                    checked={!!data.document_checklist[key]}
                    onCheckedChange={() => toggleDoc(key)}
                  />
                  <span className="text-sm font-medium uppercase">{key}</span>
                </label>
              ))}
            </div>
          </div>

          <DialogFooter>
            <Button
              type="button"
              variant="outline"
              className="min-h-[44px]"
              onClick={onClose}
            >
              {t("pipeline.edit_dialog.cancel")}
            </Button>
            <Button type="submit" className="min-h-[44px]" disabled={processing}>
              {t("pipeline.edit_dialog.save")}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}
