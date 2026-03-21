import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"
import { formatDistanceToNow, format, isToday, isYesterday } from "date-fns"
import { es, enUS, ru } from "date-fns/locale"

export const DATE_LOCALES: Record<string, typeof es> = { es, en: enUS, ru }

export type DateMode = "relative" | "date" | "time" | "datetime" | "short"

export function formatDate(
  date: string | Date,
  mode: DateMode = "relative",
  locale = "es",
  yesterdayLabel = "Yesterday"
): string {
  const d = typeof date === "string" ? new Date(date) : date
  const loc = DATE_LOCALES[locale] ?? es

  switch (mode) {
    case "relative":
      return formatDistanceToNow(d, { addSuffix: true, locale: loc })
    case "date":
      return format(d, "PP", { locale: loc })
    case "time":
      return format(d, "HH:mm", { locale: loc })
    case "datetime":
      return format(d, "PP HH:mm", { locale: loc })
    case "short":
      if (isToday(d)) return format(d, "HH:mm", { locale: loc })
      if (isYesterday(d)) return yesterdayLabel
      return format(d, "d MMM", { locale: loc })
  }
}

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

// Cached once at module load — CSRF token doesn't change during a page session
export const csrfToken: string =
  document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") ?? ""

export function formatBytes(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
}

export function getInitials(name: string): string {
  return name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2)
}

const COUNTRY_FLAGS: Record<string, string> = {
  AR: "\u{1F1E6}\u{1F1F7}", CO: "\u{1F1E8}\u{1F1F4}", MX: "\u{1F1F2}\u{1F1FD}", PE: "\u{1F1F5}\u{1F1EA}", VE: "\u{1F1FB}\u{1F1EA}",
  RU: "\u{1F1F7}\u{1F1FA}", UA: "\u{1F1FA}\u{1F1E6}", US: "\u{1F1FA}\u{1F1F8}", ES: "\u{1F1EA}\u{1F1F8}", BR: "\u{1F1E7}\u{1F1F7}",
  CU: "\u{1F1E8}\u{1F1FA}", EC: "\u{1F1EA}\u{1F1E8}", BO: "\u{1F1E7}\u{1F1F4}", CL: "\u{1F1E8}\u{1F1F1}", PY: "\u{1F1F5}\u{1F1FE}",
  UY: "\u{1F1FA}\u{1F1FE}", HN: "\u{1F1ED}\u{1F1F3}", SV: "\u{1F1F8}\u{1F1FB}", GT: "\u{1F1EC}\u{1F1F9}", NI: "\u{1F1F3}\u{1F1EE}",
  CR: "\u{1F1E8}\u{1F1F7}", PA: "\u{1F1F5}\u{1F1E6}", DO: "\u{1F1E9}\u{1F1F4}", PR: "\u{1F1F5}\u{1F1F7}", GQ: "\u{1F1EC}\u{1F1F6}",
  CN: "\u{1F1E8}\u{1F1F3}", IN: "\u{1F1EE}\u{1F1F3}", MA: "\u{1F1F2}\u{1F1E6}", TR: "\u{1F1F9}\u{1F1F7}", GB: "\u{1F1EC}\u{1F1E7}",
  PT: "\u{1F1F5}\u{1F1F9}", PK: "\u{1F1F5}\u{1F1F0}", BD: "\u{1F1E7}\u{1F1E9}", PH: "\u{1F1F5}\u{1F1ED}", NG: "\u{1F1F3}\u{1F1EC}",
  EG: "\u{1F1EA}\u{1F1EC}", IR: "\u{1F1EE}\u{1F1F7}", IQ: "\u{1F1EE}\u{1F1F6}", SY: "\u{1F1F8}\u{1F1FE}", AF: "\u{1F1E6}\u{1F1EB}",
  KZ: "\u{1F1F0}\u{1F1FF}", UZ: "\u{1F1FA}\u{1F1FF}", TM: "\u{1F1F9}\u{1F1F2}", GE: "\u{1F1EC}\u{1F1EA}", AM: "\u{1F1E6}\u{1F1F2}",
  AZ: "\u{1F1E6}\u{1F1FF}", BY: "\u{1F1E7}\u{1F1FE}", MD: "\u{1F1F2}\u{1F1E9}", KG: "\u{1F1F0}\u{1F1EC}", TJ: "\u{1F1F9}\u{1F1EF}",
  IL: "\u{1F1EE}\u{1F1F1}", JP: "\u{1F1EF}\u{1F1F5}", KR: "\u{1F1F0}\u{1F1F7}", VN: "\u{1F1FB}\u{1F1F3}", TH: "\u{1F1F9}\u{1F1ED}",
  AE: "\u{1F1E6}\u{1F1EA}", SA: "\u{1F1F8}\u{1F1E6}", IT: "\u{1F1EE}\u{1F1F9}", FR: "\u{1F1EB}\u{1F1F7}", DE: "\u{1F1E9}\u{1F1EA}",
}

export function countryFlag(code: string | null): string {
  if (!code) return "\u2753"
  return COUNTRY_FLAGS[code.toUpperCase()] ?? "\u{1F3F3}\uFE0F"
}

export function formatCurrency(amount: number): string {
  return new Intl.NumberFormat("es-ES", {
    style: "currency",
    currency: "EUR",
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(amount)
}

export function getOptionLabel(
  opt: { key: string; label?: string; label_es?: string; label_en?: string; label_ru?: string },
  locale: string
): string {
  const key = `label_${locale}` as keyof typeof opt
  return (opt[key] as string) || opt.label || opt.key
}
