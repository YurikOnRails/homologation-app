import { initSentry } from "@/lib/sentry"
import "@/lib/i18n" // Must be imported BEFORE any components
import { createInertiaApp, type ResolvedComponent } from "@inertiajs/react"
import { router } from "@inertiajs/react"
import { StrictMode } from "react"
import { createRoot } from "react-dom/client"
import { AuthLayout } from "@/components/layout/AuthLayout"
import { initCookieConsent, setCookieConsentLanguage } from "@/lib/cookieConsent"
import { detectLocale } from "@/lib/consent"

void createInertiaApp({
  resolve: async (name) => {
    const pages = import.meta.glob<{ default: ResolvedComponent }>(
      "../pages/**/*.tsx",
    )
    const loader = pages[`../pages/${name}.tsx`]
    if (!loader) {
      throw new Error(`Missing Inertia page component: '${name}.tsx'`)
    }

    const page = await loader()

    // Auth pages get AuthLayout as default persistent layout.
    // Authenticated pages manage their own layout (AuthenticatedLayout)
    // in the component JSX — this avoids double-rendering.
    if (page?.default) {
      const isAuthPage = name.startsWith("auth/")
      if (isAuthPage && !page.default.layout) {
        page.default.layout = (children: React.ReactNode) => (
          <AuthLayout>{children}</AuthLayout>
        )
      }
    }

    return page
  },

  setup({ el, App, props }) {
    initSentry()
    initCookieConsent()
    router.on("navigate", () => {
      setCookieConsentLanguage(detectLocale())
    })
    createRoot(el).render(
      <StrictMode>
        <App {...props} />
      </StrictMode>
    )
  },

  defaults: {
    form: {
      forceIndicesArrayFormatInFormData: false,
      withAllErrors: true,
    },
    future: {
      useScriptElementForInitialPage: true,
      useDataInertiaHeadAttribute: true,
      useDialogForErrorModal: true,
      preserveEqualProps: true,
    },
  },
}).catch((error) => {
  if (document.getElementById("app")) {
    throw error
  } else {
    console.error(
      "Missing root element.\n\n" +
        "If you see this error, it probably means you loaded Inertia.js on non-Inertia pages.\n" +
        'Consider moving <%= vite_typescript_tag "inertia.tsx" %> to the Inertia-specific layout instead.'
    )
  }
})
