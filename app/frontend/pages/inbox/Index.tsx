import { useState } from "react"
import { router, usePage } from "@inertiajs/react"
import { useTranslation } from "react-i18next"
import { ArrowLeft } from "lucide-react"
import { Button } from "@/components/ui/button"
import { ConversationList } from "@/components/inbox/ConversationList"
import { ChatPanel } from "@/components/inbox/ChatPanel"
import { ContextPanel } from "@/components/inbox/ContextPanel"
import { routes } from "@/lib/routes"
import type { SharedProps } from "@/types/index"
import type { InboxIndexProps, InboxConversationDetail } from "@/types/pages"

type MobileView = "list" | "chat"

export default function InboxIndex() {
  const { t } = useTranslation()
  const { conversations, selectedConversation: initialSelected = null } =
    usePage<SharedProps & InboxIndexProps>().props

  const [selected, setSelected] = useState<InboxConversationDetail | null>(initialSelected)
  const [mobileView, setMobileView] = useState<MobileView>(initialSelected ? "chat" : "list")
  const [contextOpen, setContextOpen] = useState(false)

  const handleSelect = (id: number) => {
    router.visit(routes.inboxConversation(id), {
      preserveState: true,
      only: ["selectedConversation", "conversations"],
      onSuccess: (page) => {
        const props = page.props as { selectedConversation?: InboxConversationDetail }
        if (props.selectedConversation) {
          setSelected(props.selectedConversation)
          setMobileView("chat")
        }
      },
    })
  }

  const handleBack = () => {
    setMobileView("list")
    setSelected(null)
  }

  return (
    <div className="flex h-[calc(100vh-4rem)] flex-col">
      <div className="border-b px-4 py-3 shrink-0">
        <h1 className="text-xl font-bold">{t("inbox.title")}</h1>
      </div>

      {/* Desktop: 3-column layout */}
      <div className="hidden md:flex flex-1 overflow-hidden">
        <div className="w-72 shrink-0 border-r overflow-hidden">
          <ConversationList
            conversations={conversations}
            selectedId={selected?.id ?? null}
            onSelect={handleSelect}
          />
        </div>

        <div className="flex-1 overflow-hidden">
          {selected ? (
            <ChatPanel conversation={selected} />
          ) : (
            <div className="flex h-full items-center justify-center text-sm text-muted-foreground">
              {t("inbox.no_conversations")}
            </div>
          )}
        </div>

        {selected && (
          <div className="w-64 shrink-0 overflow-hidden">
            <ContextPanel conversation={selected} />
          </div>
        )}
      </div>

      {/* Mobile: single-column with back navigation */}
      <div className="flex md:hidden flex-1 overflow-hidden flex-col">
        {mobileView === "list" ? (
          <ConversationList
            conversations={conversations}
            selectedId={selected?.id ?? null}
            onSelect={handleSelect}
          />
        ) : selected ? (
          <>
            <div className="flex items-center gap-2 border-b px-3 py-2 shrink-0">
              <Button variant="ghost" size="icon" className="h-8 w-8" onClick={handleBack}>
                <ArrowLeft className="h-4 w-4" />
              </Button>
              <span className="truncate text-sm font-semibold">{selected.title}</span>
              <Button
                variant="outline"
                size="sm"
                className="ml-auto h-7 text-xs"
                onClick={() => setContextOpen(!contextOpen)}
              >
                {t("common.filter")}
              </Button>
            </div>
            {contextOpen && (
              <div className="border-b max-h-64 overflow-y-auto shrink-0">
                <ContextPanel conversation={selected} />
              </div>
            )}
            <div className="flex-1 overflow-hidden">
              <ChatPanel conversation={selected} />
            </div>
          </>
        ) : null}
      </div>
    </div>
  )
}
