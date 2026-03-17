import { Link, usePage } from "@inertiajs/react"
import { useTranslation } from "react-i18next"
import { User2, Lock, Bell } from "lucide-react"
import { cn } from "@/lib/utils"
import { routes } from "@/lib/routes"

const NAV_ITEMS = [
  { href: routes.settings.profile, icon: User2, labelKey: "settings.nav.profile" },
  { href: routes.settings.account, icon: Lock, labelKey: "settings.nav.account" },
  { href: routes.settings.notifications, icon: Bell, labelKey: "settings.nav.notifications" },
] as const

export function SettingsLayout({ children }: { children: React.ReactNode }) {
  const { t } = useTranslation()
  const { url } = usePage()

  return (
    <div className="flex flex-col space-y-8 lg:flex-row lg:space-x-12 lg:space-y-0">
      <aside className="lg:w-48 shrink-0">
        <nav className="flex flex-row gap-1 overflow-x-auto pb-2 lg:flex-col lg:overflow-x-visible lg:pb-0">
          {NAV_ITEMS.map(({ href, icon: Icon, labelKey }) => (
            <Link
              key={href}
              href={href}
              className={cn(
                "flex items-center gap-2 rounded-md px-3 py-2 text-sm font-medium whitespace-nowrap transition-colors hover:bg-muted hover:text-foreground",
                url.startsWith(href)
                  ? "bg-muted text-foreground"
                  : "text-muted-foreground"
              )}
            >
              <Icon className="h-4 w-4 shrink-0" />
              {t(labelKey)}
            </Link>
          ))}
        </nav>
      </aside>
      <div className="flex-1 min-w-0">{children}</div>
    </div>
  )
}
