import { ChatWindow } from "@/components/chat/ChatWindow"
import { routes } from "@/lib/routes"
import type { InboxConversationDetail } from "@/types/pages"

interface ChatPanelProps {
  conversation: InboxConversationDetail
}

export function ChatPanel({ conversation }: ChatPanelProps) {
  return (
    <div className="flex h-full flex-col">
      <div className="border-b px-4 py-2">
        <h2 className="truncate text-sm font-semibold">{conversation.title}</h2>
      </div>
      <div className="flex-1 overflow-hidden">
        <ChatWindow
          conversationId={conversation.id}
          messages={conversation.messages}
          postUrl={routes.conversationMessages(conversation.id)}
        />
      </div>
    </div>
  )
}
