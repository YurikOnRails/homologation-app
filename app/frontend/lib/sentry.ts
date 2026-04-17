import * as Sentry from "@sentry/react"

function meta(name: string): string | undefined {
  return document.querySelector<HTMLMetaElement>(`meta[name="${name}"]`)?.content || undefined
}

let initialized = false

export function initSentry(): void {
  if (initialized) return
  const dsn = meta("sentry-dsn")
  if (!dsn) return

  initialized = true
  Sentry.init({
    dsn,
    environment: meta("sentry-environment") || "production",
    release: meta("sentry-release"),
    tracesSampleRate: Number(meta("sentry-traces-sample-rate") || "0.1"),
    sendDefaultPii: false,

    beforeSend(event) {
      if (event.request?.url) {
        try {
          const u = new URL(event.request.url)
          u.search = ""
          event.request.url = u.toString()
        } catch {
          // ignore unparseable URLs
        }
      }
      if (event.request?.headers) {
        delete event.request.headers["Cookie"]
        delete event.request.headers["cookie"]
        delete event.request.headers["Authorization"]
        delete event.request.headers["authorization"]
      }
      return event
    },

    ignoreErrors: [
      "ResizeObserver loop limit exceeded",
      "Non-Error promise rejection captured",
    ],
  })
}
