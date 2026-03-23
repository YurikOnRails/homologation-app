import { useState } from "react"
import { Link, usePage } from "@inertiajs/react"
import { useTranslation } from "react-i18next"
import { Rocket, Menu, X } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Sheet, SheetContent, SheetTrigger, SheetTitle } from "@/components/ui/sheet"
import { PublicLanguageSwitcher } from "@/components/public/PublicLanguageSwitcher"
import { publicRoute, publicPages, routes } from "@/lib/routes"
import type { PublicPageProps } from "@/types/pages"

interface PublicLayoutProps {
  children: React.ReactNode
}

function useLocale(): string {
  const props = usePage<PublicPageProps>().props
  return props.seo?.locale ?? "en"
}

export function PublicLayout({ children }: PublicLayoutProps) {
  const { t } = useTranslation()
  const [open, setOpen] = useState(false)
  const locale = useLocale()

  return (
    <div className="min-h-screen flex flex-col">
      <Navbar t={t} locale={locale} open={open} setOpen={setOpen} />
      <main className="flex-1">{children}</main>
      <Footer t={t} locale={locale} />
    </div>
  )
}

function Navbar({
  t,
  locale,
  open,
  setOpen,
}: {
  t: (key: string) => string
  locale: string
  open: boolean
  setOpen: (v: boolean) => void
}) {
  const navLinks = [
    { key: "homologacion", href: publicRoute(publicPages.homologacion, locale) },
    { key: "universidad", href: publicRoute(publicPages.universidad, locale) },
    { key: "espanol", href: publicRoute(publicPages.espanol, locale) },
    { key: "consulta", href: publicRoute(publicPages.consulta, locale) },
    { key: "precios", href: publicRoute(publicPages.precios, locale) },
  ]

  return (
    <header className="sticky top-0 z-50 w-full border-b bg-white/80 backdrop-blur-md">
      <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-4 sm:px-6 lg:px-8">
        {/* Logo */}
        <Link href={publicRoute(publicPages.home, locale)} className="flex items-center gap-2">
          <Rocket className="h-7 w-7 text-[#E8453C]" />
          <span className="text-xl font-bold tracking-tight">
            Space for <span className="text-[#2D7FF9]">Edu</span>
          </span>
        </Link>

        {/* Desktop nav */}
        <nav className="hidden lg:flex items-center gap-1">
          {navLinks.map(({ key, href }) => (
            <Link
              key={key}
              href={href}
              className="px-3 py-2 text-sm font-medium text-muted-foreground hover:text-foreground transition-colors rounded-md hover:bg-muted/50"
            >
              {t(`public.nav.${key}`)}
            </Link>
          ))}
        </nav>

        {/* Desktop right */}
        <div className="hidden lg:flex items-center gap-3">
          <PublicLanguageSwitcher />
          <Link href={routes.login}>
            <Button variant="outline" className="min-h-[44px]">
              {t("auth.sign_in")}
            </Button>
          </Link>
          <Link href={routes.register}>
            <Button className="min-h-[44px] bg-gradient-to-r from-[#E8453C] to-[#2D7FF9] hover:opacity-90 border-0">
              {t("public.nav.start")}
            </Button>
          </Link>
        </div>

        {/* Mobile hamburger */}
        <div className="flex lg:hidden items-center gap-2">
          <PublicLanguageSwitcher />
          <Sheet open={open} onOpenChange={setOpen}>
            <SheetTrigger asChild>
              <Button variant="ghost" size="icon" className="size-10" aria-label={t("common.menu")}>
                {open ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
              </Button>
            </SheetTrigger>
            <SheetContent side="right" className="w-80 pt-10">
              <SheetTitle className="sr-only">Menu</SheetTitle>
              <nav className="flex flex-col gap-1 mt-4">
                {navLinks.map(({ key, href }) => (
                  <Link
                    key={key}
                    href={href}
                    onClick={() => setOpen(false)}
                    className="px-4 py-3 text-base font-medium text-foreground hover:bg-muted rounded-md transition-colors"
                  >
                    {t(`public.nav.${key}`)}
                  </Link>
                ))}
                <div className="border-t my-4" />
                <Link href={routes.login} onClick={() => setOpen(false)}>
                  <Button variant="outline" className="w-full min-h-[44px]">
                    {t("auth.sign_in")}
                  </Button>
                </Link>
                <Link href={routes.register} onClick={() => setOpen(false)}>
                  <Button className="w-full min-h-[44px] mt-2 bg-gradient-to-r from-[#E8453C] to-[#2D7FF9] hover:opacity-90 border-0">
                    {t("public.nav.start")}
                  </Button>
                </Link>
              </nav>
            </SheetContent>
          </Sheet>
        </div>
      </div>
    </header>
  )
}

function Footer({ t, locale }: { t: (key: string) => string; locale: string }) {
  return (
    <footer className="border-t bg-zinc-900 text-zinc-400">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-12 sm:py-16">
        <div className="grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
          {/* Brand */}
          <div className="sm:col-span-2 lg:col-span-1">
            <div className="flex items-center gap-2 mb-4">
              <Rocket className="h-6 w-6 text-[#E8453C]" />
              <span className="text-lg font-bold text-white">
                Space for <span className="text-[#2D7FF9]">Edu</span>
              </span>
            </div>
            <p className="text-sm leading-relaxed">
              {t("public.footer.tagline")}
            </p>
          </div>

          {/* Services */}
          <div>
            <h3 className="text-sm font-semibold text-white mb-4">
              {t("public.footer.services")}
            </h3>
            <ul className="space-y-2 text-sm">
              <li>
                <Link href={publicRoute(publicPages.homologacion, locale)} className="hover:text-white transition-colors">
                  {t("public.nav.homologacion")}
                </Link>
              </li>
              <li>
                <Link href={publicRoute(publicPages.universidad, locale)} className="hover:text-white transition-colors">
                  {t("public.nav.universidad")}
                </Link>
              </li>
              <li>
                <Link href={publicRoute(publicPages.espanol, locale)} className="hover:text-white transition-colors">
                  {t("public.nav.espanol")}
                </Link>
              </li>
            </ul>
          </div>

          {/* Company */}
          <div>
            <h3 className="text-sm font-semibold text-white mb-4">
              {t("public.footer.company")}
            </h3>
            <ul className="space-y-2 text-sm">
              <li>
                <Link href={publicRoute(publicPages.precios, locale)} className="hover:text-white transition-colors">
                  {t("public.nav.precios")}
                </Link>
              </li>
              <li>
                <Link href={publicRoute(publicPages.consulta, locale)} className="hover:text-white transition-colors">
                  {t("public.nav.consulta")}
                </Link>
              </li>
              <li>
                <Link href={routes.privacyPolicy} className="hover:text-white transition-colors">
                  {t("public.footer.privacy")}
                </Link>
              </li>
            </ul>
          </div>

          {/* Contact */}
          <div>
            <h3 className="text-sm font-semibold text-white mb-4">
              {t("public.footer.contact")}
            </h3>
            <ul className="space-y-2 text-sm">
              <li>{t("public.footer.email")}</li>
              <li>{t("public.footer.phone")}</li>
              <li>{t("public.footer.address")}</li>
            </ul>
          </div>
        </div>

        <div className="border-t border-zinc-800 mt-10 pt-6 text-center text-xs text-zinc-500">
          © {new Date().getFullYear()} Space for Edu. {t("public.footer.rights")}
        </div>
      </div>
    </footer>
  )
}
