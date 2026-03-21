import { useState, useCallback, useRef, useEffect } from "react"
import { router, usePage } from "@inertiajs/react"
import { useTranslation } from "react-i18next"
import { Search } from "lucide-react"
import { Input } from "@/components/ui/input"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { routes } from "@/lib/routes"
import { getOptionLabel } from "@/lib/utils"
import type { SharedProps } from "@/types"
import type { PipelineFilters } from "@/types/pages"

interface FilterBarProps {
  filters: PipelineFilters
}

export function FilterBar({ filters }: FilterBarProps) {
  const { t, i18n } = useTranslation()
  const { selectOptions } = usePage<SharedProps>().props
  const [search, setSearch] = useState(filters.q ?? "")
  const debounceRef = useRef<ReturnType<typeof setTimeout>>(null)

  const serviceTypes = selectOptions.service_types ?? []

  const applyFilters = useCallback(
    (updates: Partial<PipelineFilters>) => {
      const merged = { ...filters, ...updates }
      const params: Record<string, string> = {}
      if (merged.q) params.q = merged.q
      if (merged.year) params.year = merged.year
      if (merged.cotejoRoute) params.cotejo_route = merged.cotejoRoute
      if (merged.serviceType) params.service_type = merged.serviceType

      router.get(routes.admin.pipeline, params, {
        preserveState: true,
        replace: true,
      })
    },
    [filters]
  )

  const handleSearch = useCallback(
    (value: string) => {
      setSearch(value)
      if (debounceRef.current) clearTimeout(debounceRef.current)
      debounceRef.current = setTimeout(() => {
        applyFilters({ q: value || null })
      }, 300)
    },
    [applyFilters]
  )

  useEffect(() => {
    return () => {
      if (debounceRef.current) clearTimeout(debounceRef.current)
    }
  }, [])

  const currentYear = new Date().getFullYear()
  const years = [currentYear, currentYear - 1]

  return (
    <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
      <div className="relative flex-1">
        <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
        <Input
          placeholder={t("pipeline.search_placeholder")}
          value={search}
          onChange={(e) => handleSearch(e.target.value)}
          className="pl-9"
        />
      </div>
      <Select
        value={filters.year ?? "all"}
        onValueChange={(v) => applyFilters({ year: v === "all" ? null : v })}
      >
        <SelectTrigger className="w-full sm:w-[120px]">
          <SelectValue placeholder={t("pipeline.filters.year")} />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="all">{t("pipeline.filters.all")}</SelectItem>
          {years.map((y) => (
            <SelectItem key={y} value={String(y)}>{y}</SelectItem>
          ))}
        </SelectContent>
      </Select>
      <Select
        value={filters.cotejoRoute ?? "all"}
        onValueChange={(v) => applyFilters({ cotejoRoute: v === "all" ? null : v })}
      >
        <SelectTrigger className="w-full sm:w-[160px]">
          <SelectValue placeholder={t("pipeline.filters.cotejo_route")} />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="all">{t("pipeline.filters.all")}</SelectItem>
          <SelectItem value="ministerio">{t("pipeline.filters.ministerio")}</SelectItem>
          <SelectItem value="delegacion">{t("pipeline.filters.delegacion")}</SelectItem>
          <SelectItem value="unknown">{t("pipeline.filters.no_country")}</SelectItem>
        </SelectContent>
      </Select>
      <Select
        value={filters.serviceType ?? "all"}
        onValueChange={(v) => applyFilters({ serviceType: v === "all" ? null : v })}
      >
        <SelectTrigger className="w-full sm:w-[140px]">
          <SelectValue placeholder={t("pipeline.filters.service_type")} />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="all">{t("pipeline.filters.all")}</SelectItem>
          {serviceTypes.map((opt) => (
            <SelectItem key={opt.key} value={opt.key}>
              {getOptionLabel(opt, i18n.language)}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
    </div>
  )
}
