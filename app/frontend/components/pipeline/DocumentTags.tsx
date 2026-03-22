import { cn } from "@/lib/utils"
import { DOC_KEYS } from "@/components/pipeline/constants"

interface DocumentTagsProps {
  checklist: Record<string, boolean>
  complete: number
  total: number
}

export function DocumentTags({ checklist }: DocumentTagsProps) {
  return (
    <div className="flex flex-wrap gap-0.5">
      {DOC_KEYS.map((key) => (
        <span
          key={key}
          className={cn(
            "text-[11px] font-bold px-1.5 py-0.5 rounded uppercase leading-none",
            checklist[key]
              ? "bg-emerald-700/80 text-white"
              : "bg-slate-200 text-slate-500"
          )}
        >
          {key}
        </span>
      ))}
    </div>
  )
}
