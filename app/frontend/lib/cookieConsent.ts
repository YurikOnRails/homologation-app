import * as CookieConsent from "vanilla-cookieconsent"
import "vanilla-cookieconsent/dist/cookieconsent.css"
import { syncConsentMode, detectLocale } from "@/lib/consent"

type Locale = "en" | "es" | "ru"

const TRANSLATIONS: Record<Locale, CookieConsent.Translation> = {
  en: {
    consentModal: {
      title: "We value your privacy",
      description:
        "We use cookies to measure traffic, improve the site, and — with your consent — personalize ads. You can accept, reject, or customize which categories we may use.",
      acceptAllBtn: "Accept all",
      acceptNecessaryBtn: "Reject all",
      showPreferencesBtn: "Customize",
      footer: '<a href="/privacy-policy">Privacy Policy</a>',
    },
    preferencesModal: {
      title: "Cookie preferences",
      acceptAllBtn: "Accept all",
      acceptNecessaryBtn: "Reject all",
      savePreferencesBtn: "Save preferences",
      closeIconLabel: "Close",
      sections: [
        {
          title: "Cookie usage",
          description:
            "We use cookies to keep the site working, understand how it is used, and improve your experience. Strictly necessary cookies cannot be disabled.",
        },
        {
          title: "Strictly necessary",
          description:
            "Required for the site to function: authentication, session, security, and preferences.",
          linkedCategory: "necessary",
        },
        {
          title: "Analytics",
          description:
            "Help us understand how visitors use the site (Google Analytics 4, Yandex.Metrica, Microsoft Clarity). Data is aggregated and pseudonymized.",
          linkedCategory: "analytics",
        },
        {
          title: "Marketing",
          description:
            "Used to show relevant ads and measure campaign performance (Meta Pixel, Google Ads). You can opt out at any time.",
          linkedCategory: "marketing",
        },
        {
          title: "More information",
          description:
            'For questions about our cookie policy, please see our <a href="/privacy-policy">Privacy Policy</a>.',
        },
      ],
    },
  },
  es: {
    consentModal: {
      title: "Respetamos tu privacidad",
      description:
        "Usamos cookies para medir el tráfico, mejorar el sitio y — con tu consentimiento — personalizar la publicidad. Puedes aceptar, rechazar o personalizar qué categorías utilizamos.",
      acceptAllBtn: "Aceptar todas",
      acceptNecessaryBtn: "Rechazar todas",
      showPreferencesBtn: "Personalizar",
      footer: '<a href="/privacy-policy">Política de privacidad</a>',
    },
    preferencesModal: {
      title: "Preferencias de cookies",
      acceptAllBtn: "Aceptar todas",
      acceptNecessaryBtn: "Rechazar todas",
      savePreferencesBtn: "Guardar preferencias",
      closeIconLabel: "Cerrar",
      sections: [
        {
          title: "Uso de cookies",
          description:
            "Usamos cookies para mantener el sitio en funcionamiento, entender cómo se usa y mejorar tu experiencia. Las cookies estrictamente necesarias no se pueden desactivar.",
        },
        {
          title: "Estrictamente necesarias",
          description:
            "Necesarias para que el sitio funcione: autenticación, sesión, seguridad y preferencias.",
          linkedCategory: "necessary",
        },
        {
          title: "Analítica",
          description:
            "Nos ayudan a entender cómo se usa el sitio (Google Analytics 4, Yandex.Metrica, Microsoft Clarity). Los datos se agregan y seudonimizan.",
          linkedCategory: "analytics",
        },
        {
          title: "Marketing",
          description:
            "Se usan para mostrarte anuncios relevantes y medir campañas (Meta Pixel, Google Ads). Puedes darte de baja en cualquier momento.",
          linkedCategory: "marketing",
        },
        {
          title: "Más información",
          description:
            'Para preguntas sobre nuestra política de cookies, consulta nuestra <a href="/privacy-policy">Política de privacidad</a>.',
        },
      ],
    },
  },
  ru: {
    consentModal: {
      title: "Мы ценим вашу конфиденциальность",
      description:
        "Мы используем cookies для измерения посещаемости, улучшения сайта и — с вашего согласия — для персонализации рекламы. Вы можете принять, отклонить или настроить категории.",
      acceptAllBtn: "Принять все",
      acceptNecessaryBtn: "Отклонить все",
      showPreferencesBtn: "Настроить",
      footer: '<a href="/privacy-policy">Политика конфиденциальности</a>',
    },
    preferencesModal: {
      title: "Настройки cookies",
      acceptAllBtn: "Принять все",
      acceptNecessaryBtn: "Отклонить все",
      savePreferencesBtn: "Сохранить настройки",
      closeIconLabel: "Закрыть",
      sections: [
        {
          title: "Использование cookies",
          description:
            "Мы используем cookies, чтобы сайт работал, понимать как им пользуются и улучшать ваш опыт. Строго необходимые cookies нельзя отключить.",
        },
        {
          title: "Строго необходимые",
          description:
            "Требуются для работы сайта: аутентификация, сессия, безопасность и настройки.",
          linkedCategory: "necessary",
        },
        {
          title: "Аналитика",
          description:
            "Помогают понять, как используется сайт (Google Analytics 4, Yandex.Metrica, Microsoft Clarity). Данные агрегированы и псевдонимизированы.",
          linkedCategory: "analytics",
        },
        {
          title: "Маркетинг",
          description:
            "Используются для показа релевантной рекламы и измерения кампаний (Meta Pixel, Google Ads). Вы можете отказаться в любое время.",
          linkedCategory: "marketing",
        },
        {
          title: "Дополнительная информация",
          description:
            'По вопросам о нашей политике cookies смотрите <a href="/privacy-policy">Политику конфиденциальности</a>.',
        },
      ],
    },
  },
}

let initialized = false

export function initCookieConsent(): void {
  if (initialized) return
  initialized = true

  const locale = detectLocale()

  CookieConsent.run({
    mode: "opt-in",
    revision: 1,
    autoShow: true,
    hideFromBots: true,

    cookie: {
      name: "cc_cookie",
      expiresAfterDays: 182,
      sameSite: "Lax",
    },

    guiOptions: {
      consentModal: {
        layout: "box",
        position: "bottom right",
        equalWeightButtons: true,
        flipButtons: false,
      },
      preferencesModal: {
        layout: "box",
        position: "right",
        equalWeightButtons: true,
        flipButtons: false,
      },
    },

    categories: {
      necessary: {
        enabled: true,
        readOnly: true,
      },
      analytics: {},
      marketing: {},
    },

    language: {
      default: locale,
      translations: TRANSLATIONS,
    },

    onConsent: ({ cookie }) => {
      syncConsentMode(cookie.categories as ("necessary" | "analytics" | "marketing")[])
    },
    onChange: ({ cookie }) => {
      syncConsentMode(cookie.categories as ("necessary" | "analytics" | "marketing")[])
    },
  })
}

export function setCookieConsentLanguage(locale: Locale): void {
  if (!initialized) return
  CookieConsent.setLanguage(locale, true)
}

export function showCookiePreferences(): void {
  CookieConsent.showPreferences()
}
