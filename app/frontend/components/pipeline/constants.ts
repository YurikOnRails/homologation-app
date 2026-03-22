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

/** Stage color palette — accent color for column headers and card left borders */
export const STAGE_COLORS: Record<string, { border: string; bg: string; text: string; dot: string }> = {
  pago_recibido:     { border: "border-l-amber-400",   bg: "bg-amber-500",   text: "text-amber-700",   dot: "bg-amber-400" },
  documentos:        { border: "border-l-blue-400",    bg: "bg-blue-500",    text: "text-blue-700",    dot: "bg-blue-400" },
  traduccion:        { border: "border-l-emerald-400", bg: "bg-emerald-500", text: "text-emerald-700", dot: "bg-emerald-400" },
  tasas_volantes:    { border: "border-l-orange-400",  bg: "bg-orange-500",  text: "text-orange-700",  dot: "bg-orange-400" },
  redsara:           { border: "border-l-violet-400",  bg: "bg-violet-500",  text: "text-violet-700",  dot: "bg-violet-400" },
  cotejo_ministerio: { border: "border-l-pink-400",    bg: "bg-pink-500",    text: "text-pink-700",    dot: "bg-pink-400" },
  cotejo_delegacion: { border: "border-l-cyan-400",    bg: "bg-cyan-500",    text: "text-cyan-700",    dot: "bg-cyan-400" },
  completado:        { border: "border-l-green-400",   bg: "bg-green-500",   text: "text-green-700",   dot: "bg-green-400" },
}
