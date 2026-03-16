import { useState } from "react"
import { useTranslation } from "react-i18next"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { ConversationItem } from "./ConversationItem"
import type { InboxConversation } from "@/types/pages"

type FilterType = "all" | "requests" | "teacher_chats" | "unread"

interface ConversationListProps {
  conversations: InboxConversation[]
  selectedId: number | null
  onSelect: (id: number) => void
}

export function ConversationList({ conversations, selectedId, onSelect }: ConversationListProps) {
  const { t } = useTranslation()
  const [search, setSearch] = useState("")
  const [filter, setFilter] = useState<FilterType>("all")

  const filtered = conversations.filter((c) => {
    if (filter === "requests" && c.type !== "request") return false
    if (filter === "teacher_chats" && c.type !== "teacher_student") return false
    if (filter === "unread" && !c.unread) return false
    if (search && !c.title.toLowerCase().includes(search.toLowerCase())) return false
    return true
  })

  const filters: { key: FilterType; label: string }[] = [
    { key: "all", label: t("inbox.all") },
    { key: "requests", label: t("inbox.requests_filter") },
    { key: "teacher_chats", label: t("inbox.teacher_chats") },
    { key: "unread", label: t("inbox.unread_only") },
  ]

  return (
    <div className="flex h-full flex-col">
      <div className="border-b p-3 space-y-2">
        <Input
          placeholder={t("inbox.search")}
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="h-8 text-sm"
        />
        <div className="flex flex-wrap gap-1">
          {filters.map((f) => (
            <Button
              key={f.key}
              variant={filter === f.key ? "secondary" : "ghost"}
              size="sm"
              className="h-7 text-xs px-2"
              onClick={() => setFilter(f.key)}
            >
              {f.label}
            </Button>
          ))}
        </div>
      </div>
      <div className="flex-1 overflow-y-auto p-2 space-y-1">
        {filtered.length === 0 ? (
          <p className="py-8 text-center text-sm text-muted-foreground">{t("inbox.no_conversations")}</p>
        ) : (
          filtered.map((c) => (
            <ConversationItem
              key={c.id}
              conversation={c}
              isSelected={c.id === selectedId}
              onClick={() => onSelect(c.id)}
            />
          ))
        )}
      </div>
    </div>
  )
}
