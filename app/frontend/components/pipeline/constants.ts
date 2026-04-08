import { useMemo } from "react"
import { usePage } from "@inertiajs/react"
import type { SharedProps } from "@/types/index"

// ─── Color palette ──────────────────────────────────────────────────────────
// Maps the `color` field from config/pipeline.yml to Tailwind classes.

const MONO = { border: "border-border", bg: "bg-primary", text: "text-muted-foreground", dot: "bg-muted-foreground" }

const COLOR_PALETTE: Record<string, { border: string; bg: string; text: string; dot: string }> = {
  amber: MONO, blue: MONO, emerald: MONO, orange: MONO, violet: MONO, pink: MONO, cyan: MONO, green: MONO,
}

const DEFAULT_COLOR = MONO

// ─── Hook: pipeline config from server ──────────────────────────────────────

export interface StageColor { border: string; bg: string; text: string; dot: string; icon: string }

export function usePipeline() {
  const { pipelineConfig } = usePage<SharedProps>().props
  const stages = pipelineConfig.stages

  return useMemo(() => {
    const kanbanStages = stages.filter((s) => s.display === "kanban").map((s) => s.key)
    const horizontalStages = stages.filter((s) => s.display === "horizontal").map((s) => ({ stage: s.key, icon: s.icon }))
    const allStages = stages.map((s) => s.key)
    const docKeys = pipelineConfig.document_checklist.map((d) => d.key)

    const stageColors: Record<string, StageColor> = {}
    const stageShortLabels: Record<string, string> = {}
    for (const s of stages) {
      const palette = COLOR_PALETTE[s.color] ?? DEFAULT_COLOR
      stageColors[s.key] = { ...palette, icon: s.icon }
      stageShortLabels[s.key] = s.short
    }

    return { kanbanStages, horizontalStages, allStages, docKeys, stageColors, stageShortLabels, stages }
  }, [pipelineConfig])
}

// ─── Static constants (not from config) ─────────────────────────────────────

export const CURRENT_YEAR = new Date().getFullYear()

const OUTLINE_BADGE = { bg: "bg-transparent border border-border", text: "text-foreground" }
const OUTLINE_DASHED = { bg: "bg-transparent border border-dashed border-border", text: "text-foreground" }

export const YEAR_COLORS: Record<number, { bg: string; text: string }> = {
  [CURRENT_YEAR - 1]: OUTLINE_BADGE,
  [CURRENT_YEAR]:     OUTLINE_BADGE,
  [CURRENT_YEAR + 1]: OUTLINE_BADGE,
}

export const SERVICE_TYPE_COLORS: Record<string, { bg: string; text: string }> = {
  homologacion: OUTLINE_DASHED,
  equivalencia: OUTLINE_DASHED,
  uned:         OUTLINE_DASHED,
}
