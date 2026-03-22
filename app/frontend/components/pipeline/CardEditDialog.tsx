import { useEffect } from "react"
import { Link, useForm } from "@inertiajs/react"
import { useTranslation } from "react-i18next"
import { ExternalLink } from "lucide-react"
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
import { Button } from "@/components/ui/button"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { routes } from "@/lib/routes"
import { CURRENT_YEAR } from "@/components/pipeline/constants"
import type { PipelineCard } from "@/types/pages"

interface CardEditDialogProps {
  card: PipelineCard | null
  open: boolean
  onClose: () => void
}

const YEARS = [CURRENT_YEAR - 1, CURRENT_YEAR, CURRENT_YEAR + 1]

export function CardEditDialog({ card, open, onClose }: CardEditDialogProps) {
  const { t } = useTranslation()
  const { data, setData, patch, processing, clearErrors } = useForm({
    pipeline_notes: "",
    payment_amount: 0,
    year: CURRENT_YEAR,
  })

  useEffect(() => {
    if (card) {
      clearErrors()
      setData({
        pipeline_notes: card.pipelineNotes ?? "",
        payment_amount: card.amount,
        year: card.year,
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

  return (
    <Dialog open={open} onOpenChange={(v) => !v && onClose()}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>{t("pipeline.edit_dialog.title")}</DialogTitle>
          {card && (
            <div className="flex items-center gap-2">
              <p className="text-sm text-muted-foreground">{card.studentName}</p>
              <Link
                href={routes.request(card.id)}
                className="inline-flex items-center gap-1 text-xs text-primary hover:underline"
                onClick={(e) => e.stopPropagation()}
              >
                {t("pipeline.edit_dialog.view_request")}
                <ExternalLink className="h-3 w-3" />
              </Link>
            </div>
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
