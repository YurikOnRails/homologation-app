# SEO & Analytics — Sprint 1 deployment guide

This file is the handover for all SEO + tracking + error-monitoring infrastructure added in Sprint 1. Code is in place — what remains is **configuration in third-party tools** and **setting env vars**.

## Single source of truth: `.env.example`

Every env var the app reads is listed and grouped in [`.env.example`](../.env.example). Copy it to `.env` for local dev. For production Kamal deploys:

- Non-sensitive values → `config/deploy.yml` under `env.clear`
- Sensitive values (backend Sentry DSN, etc.) → `.kamal/secrets`, then listed under `env.secret`

## Env var reference

| Variable | Purpose | Where to get it | Sensitive? |
|---|---|---|---|
| `APP_HOST_URL` | Absolute canonical host (e.g. `https://spaceforedu.com`) — used in sitemap, canonical URLs, Schema.org `@id` | Your domain | No |
| `GTM_ID` | Google Tag Manager container ID (`GTM-XXXXXXX`). The ONE env var for tracking — all tools (GA4, Metrica, Clarity, Meta Pixel) are configured inside GTM. | tagmanager.google.com | No |
| `GOOGLE_SITE_VERIFICATION` | `google-site-verification` meta tag content | Search Console → Settings → Ownership verification → HTML tag | No |
| `YANDEX_VERIFICATION` | `yandex-verification` meta tag content | webmaster.yandex.com → Add site → Meta tag | No |
| `BING_SITE_VERIFICATION` | `msvalidate.01` meta tag content | bing.com/webmasters → Add site → Meta tag | No |
| `FACEBOOK_DOMAIN_VERIFICATION` | Meta Business domain verification | business.facebook.com → Business settings → Brand safety → Domains | No |
| `SENTRY_DSN_BACKEND` | Sentry Rails project DSN — server-side errors | sentry.io → Create Rails project | **Yes** |
| `SENTRY_DSN_FRONTEND` | Sentry React project DSN — client-side errors (rendered in HTML meta tag) | sentry.io → Create React project | No (public by design) |
| `SENTRY_ENVIRONMENT` | Tag for Sentry events (e.g. `production`, `staging`) | — | No |
| `SENTRY_RELEASE` | Release identifier for Sentry. Common: git SHA set at build time via `KAMAL_VERSION`. | — | No |
| `SENTRY_TRACES_SAMPLE_RATE` | Performance tracing sample rate (0.0–1.0, default `0.1`) | — | No |
| `SENTRY_PROFILES_SAMPLE_RATE` | Profiling sample rate (0.0–1.0, default `0.0`) | — | No |

All values render / activate only when present. Missing vars leave the feature inert — no broken behavior.

## What's wired up (code side)

1. **Google Tag Manager** — loaded in `<head>` with Consent Mode v2 defaults firing **before** `gtm.js`. All tracking tools are configured inside the GTM UI, not in code.
2. **Consent Mode v2** — defaults to `denied` for every category except `security_storage`. Updates the moment the user makes a choice in the CMP.
3. **Cookie consent (CMP)** — `vanilla-cookieconsent` v3, 3 categories (necessary / analytics / marketing), localized es/en/ru. Banner auto-shows on first visit; users can reopen preferences from the Privacy Policy page ("Cookie settings" button).
4. **Sentry** — error tracking + performance monitoring. Backend via `sentry-rails` gem, frontend via `@sentry/react`. Frontend DSN read from a `<meta>` tag rendered by Rails (no Vite build-time env var needed). PII scrubbed: cookies, auth headers, IP, query strings removed before events ship. Processed under legitimate interest (GDPR art. 6(1)(f)) — no consent gate. Skipped entirely when DSN env var is absent.
5. **CSP** — when `GTM_ID` is set, CSP auto-expands to allow GTM, GA, Yandex.Metrica, Clarity, and Meta Pixel domains. When `SENTRY_DSN_FRONTEND` is set, CSP allows `*.sentry.io` and `*.ingest.*.sentry.io`. Strict CSP preserved when env vars are absent.
6. **Webmaster verification meta tags** — rendered in `<head>` based on env vars.
7. **Sitemap.xml** — dynamic at `/sitemap.xml`, multilingual with `xhtml:link hreflang`.
8. **robots.txt** — dynamic, references the absolute Sitemap URL, explicitly allows AI crawlers (GPTBot, ClaudeBot, PerplexityBot, Google-Extended, Applebot-Extended).
9. **Schema.org JSON-LD** — `EducationalOrganization` + `WebSite` site-wide; per-page `BreadcrumbList` + `Service` on public pages.
10. **llms.txt** — `/llms.txt` factual summary for LLM crawlers.
11. **Privacy Policy** — expanded with cookie/analytics/error-monitoring disclosure in es/en/ru.

## One-time setup tasks (your side)

### 1. GTM — create container + add tags
1. Create a GTM container at `tagmanager.google.com`. Copy the ID, set `GTM_ID`.
2. In the GTM UI, create tags (not in code):
   - **GA4 configuration tag** — Measurement ID `G-XXXXXXXX`
   - **Yandex.Metrica tag** — use the community tag template or a Custom HTML tag with the Metrica script. Counter ID from metrica.yandex.com.
   - **Microsoft Clarity tag** — Custom HTML with the Clarity snippet. Project ID from clarity.microsoft.com.
   - **Meta Pixel tag** — use the Facebook Pixel community template. Pixel ID from business.facebook.com.
3. Set **built-in consent state**:
   - GA4 → requires `analytics_storage`
   - Yandex / Clarity → fire on trigger `consent_updated` with category `analytics`
   - Meta Pixel → requires `ad_storage` + `ad_user_data` + `ad_personalization`
4. For each tag, **"Additional consent checks" → Require additional consent for tag to fire**. Otherwise the tag fires before user consent and you are non-compliant.
5. Publish the container.

### 2. Search Console (Google)
1. `search.google.com/search-console` → Add property → URL prefix → paste the domain.
2. Choose HTML tag verification. Copy the content value into `GOOGLE_SITE_VERIFICATION` env var, deploy.
3. Click "Verify". Then submit sitemap: `https://your-domain/sitemap.xml`.

### 3. Yandex Webmaster
1. `webmaster.yandex.com` → add site. Choose Meta tag. Copy the `content` into `YANDEX_VERIFICATION`, deploy, verify.
2. Submit `sitemap.xml` in the "Sitemap files" section.
3. Enable regional geo-targeting (Spain + Russia) under "Site info" if relevant.
4. Connect the Metrica counter to the webmaster account — Yandex heavily weights Metrica behavioral signals.

### 4. Bing Webmaster Tools
1. `bing.com/webmasters` → Add site. Meta tag method. Copy content into `BING_SITE_VERIFICATION`.
2. Submit `sitemap.xml`.
3. Bing indexes ChatGPT Search and Copilot — verify here even if Bing traffic is small.

### 5. Meta Business / Facebook domain verification
1. `business.facebook.com` → Business settings → Brand safety and suitability → Domains → Add domain.
2. Pick Meta tag method. Copy into `FACEBOOK_DOMAIN_VERIFICATION`.
3. After verification, enable the Meta Pixel via GTM (see step 1).

### 6. Google Business Profile
Create a profile at `business.google.com` — even for online-only businesses. Boosts brand recognition and appears in AI answers.

### 7. Sentry
1. `sentry.io` → create **two** projects: one Rails (backend), one React (frontend). Each project gets its own DSN.
2. Copy the backend DSN → `SENTRY_DSN_BACKEND` (put in `.kamal/secrets`, reference under `env.secret`).
3. Copy the frontend DSN → `SENTRY_DSN_FRONTEND` (`env.clear` is fine — this DSN is shipped to the browser by design).
4. Set `SENTRY_ENVIRONMENT=production` and optionally `SENTRY_RELEASE` (git SHA) for release tracking.
5. In the Sentry UI → Project Settings → Data Scrubbing: enable default scrubbing AND add custom rules to strip `email_address`, `phone`, `whatsapp`, `birthday`, `guardian_*`. Defense in depth on top of the server-side scrubber.
6. Performance: `SENTRY_TRACES_SAMPLE_RATE=0.1` captures 10 % of requests. Raise for staging, lower for production under high load.

## Verification checklist after deploy

```bash
curl -s https://your-domain/robots.txt | grep Sitemap
curl -s https://your-domain/sitemap.xml | head -5
curl -s https://your-domain/llms.txt | head -5
curl -s https://your-domain/ | grep -E 'google-site-verification|yandex-verification|msvalidate|GTM-'
```

Then in a browser:
- Cookie banner appears on first visit in the correct language.
- Accept / Reject / Customize buttons function.
- After accepting, `dataLayer` in DevTools contains `consent_updated` event.
- Google Tag Assistant (Chrome extension) shows GTM loaded and Consent Mode state.
- GA4 DebugView shows events flowing (only after consent).

## Known caveats

- **Consent Mode v2 modeled conversions** — Google recommends >1000 weekly ad clicks and >1000 daily users with ad consent for modeling to kick in. Early days will show less data than reality.
- **Yandex.Metrica + EU users** — Yandex is a Russian service; for EU users it requires explicit analytics consent (which the CMP handles). Consider disabling Metrica in production outside Russian-speaking regions if legal wants extra caution.
- **CSP `unsafe-inline`** — auto-enabled only when `GTM_ID` is set. GTM does not support nonce-based CSP without intrusive workarounds. Tradeoff accepted in exchange for GTM usability.
- **CMP revision** — bumping the `revision` number in `app/frontend/lib/cookieConsent.ts` forces all users to re-consent. Do this when you add a new category or materially change data practices.
