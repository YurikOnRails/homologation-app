import { cn } from "@/lib/utils"
import { DOC_KEYS } from "@/components/pipeline/constants"

interface DocumentTagsProps {
  checklist: Record<string, boolean>
  complete: number
  total: number
}

export function DocumentTags({ checklist, complete, total }: DocumentTagsProps) {
  return (
    <div className="flex items-center gap-2">
      <div className="flex flex-wrap gap-1">
        {DOC_KEYS.map((key) => (
          <span
            key={key}
            className={cn(
              "text-[10px] font-bold px-1.5 py-0.5 rounded uppercase",
              checklist[key]
                ? "bg-green-600 text-white"
                : "bg-muted text-muted-foreground"
            )}
          >
            {key}
          </span>
        ))}
      </div>
      <span className="text-xs font-medium text-muted-foreground whitespace-nowrap">
        {complete}/{total}
      </span>
    </div>
  )
}
