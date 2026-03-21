/** Document checklist keys — single source of truth for DocumentTags and CardEditDialog */
export const DOC_KEYS = ["sol", "vol", "tas", "aut", "pas", "ori", "tra", "reg", "not", "ent"] as const

/** First 5 stages shown as vertical kanban columns */
export const KANBAN_STAGES = [
  "pago_recibido",
  "documentos",
  "traduccion",
  "tasas_volantes",
  "redsara",
] as const

/** Last 3 stages shown as horizontal card rows */
export const HORIZONTAL_STAGES = [
  { stage: "cotejo_ministerio", icon: "\u{1F3DB}" },
  { stage: "cotejo_delegacion", icon: "\u{1F3E2}" },
  { stage: "completado", icon: "\u2705" },
] as const

/** All 8 stages in pipeline order (for mobile tabs) */
export const ALL_STAGES = [
  ...KANBAN_STAGES,
  ...HORIZONTAL_STAGES.map((s) => s.stage),
] as const
