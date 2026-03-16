import { useTranslation } from "react-i18next"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { FormattedDate } from "@/components/common/FormattedDate"
import { cn, getInitials } from "@/lib/utils"
import type { InboxConversation } from "@/types/pages"

interface ConversationItemProps {
  conversation: InboxConversation
  isSelected: boolean
  onClick: () => void
}

export function ConversationItem({ conversation, isSelected, onClick }: ConversationItemProps) {
  const { t } = useTranslation()
  const initials = getInitials(conversation.title)

  return (
    <button
      type="button"
      onClick={onClick}
      className={cn(
        "w-full flex items-center gap-3 px-3 py-3 text-left transition-colors hover:bg-accent/50 rounded-md",
        isSelected && "bg-accent",
        conversation.unread && "font-medium",
      )}
    >
      <Avatar className="h-9 w-9 shrink-0">
        <AvatarFallback className="text-xs">{initials}</AvatarFallback>
      </Avatar>
      <div className="min-w-0 flex-1">
        <div className="flex items-center justify-between gap-2">
          <span className="truncate text-sm">{conversation.title}</span>
          {conversation.lastMessage && (
            <span className="shrink-0 text-xs text-muted-foreground">
              <FormattedDate date={conversation.lastMessage.createdAt} />
            </span>
          )}
        </div>
        <div className="flex items-center justify-between gap-2">
          <p className="truncate text-xs text-muted-foreground">
            {conversation.lastMessage?.body ?? t("chat.no_messages")}
          </p>
          {conversation.unread && (
            <Badge variant="destructive" className="h-2 w-2 shrink-0 rounded-full p-0" />
          )}
        </div>
      </div>
    </button>
  )
}
