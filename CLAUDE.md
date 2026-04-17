# CLAUDE.md — Project Guide

## Rules for Claude

- **Never make git commits.** The user commits manually. Do not run `git commit` under any circumstances.

## What is this?

Homologation app for managing student document equivalencia requests in Spain.
Students submit requests, upload documents, chat with coordinators, and data syncs to AmoCRM after payment confirmation.
Teachers give Spanish lessons to students with calendar and video call links.
Super admin manages everything including Stripe billing.

## Tech Stack

- **Backend:** Rails 8.1.2, Ruby 3.4.9
- **Frontend:** React 19, TypeScript 5.9, Inertia.js 2.3
- **Build:** Vite 7.3, Tailwind CSS 4.2
- **UI:** shadcn/ui components (shadcn-admin layout style)
- **Database:** SQLite3
- **Auth:** Rails 8 built-in generator + OmniAuth (Google, Apple). NOT Devise.
- **Authorization:** Pundit (4 roles: super_admin, coordinator, teacher, student)
- **Payments:** Stripe (super_admin creates invoices)
- **Files:** Active Storage with direct upload (local disk, no S3)
- **Real-time:** Action Cable (Solid Cable adapter, SQLite-backed, no Redis)
- **Background jobs:** Solid Queue (SQLite-backed, no Redis)
- **CRM:** AmoCRM API via Faraday
- **Notifications:** In-app (Action Cable) + Email + Telegram Bot API (free, opt-in)
- **Testing:** Minitest
- **i18n:** 3 languages (es, en, ru) — react-i18next + Rails I18n

## Commands

`bin/rails test` · `npm run check` · `bundle exec brakeman` — run all three before committing.

## Current State

See `docs/07_IMPLEMENTATION_PLAN.md` for the full step-by-step checklist (Steps 0–10).

## Core Rules

1. **i18n** — All visible text via `t()`. Status: `t(\`requests.status.${status}\`)`. Options: `opt[label_${locale}] || opt.label`.
2. **Forms** — Inertia `useForm()` only. No zod, no react-hook-form. Server-side validation, errors via Inertia.
3. **Authorization** — `authorize @record` in every action. `after_action :verify_authorized` in ApplicationController.
4. **Files** — Active Storage direct upload via `FileDropZone`. Three categories: `:application` (one), `:originals` (many), `:documents` (many).
5. **Chat** — Send via `router.post()` (Inertia), receive via `useChannel()` hook (Action Cable).
6. **AmoCRM sync** — ONLY on payment confirmation. No data to CRM before `payment_confirmed`.
7. **Select options** — `config/select_options/*.yml` (one file per dropdown) → `inertia_share` → `selectOptions` in every page. Never hardcode — always `opt[label_${locale}] || opt.label`.
8. **Security** — `encrypts` on PII fields, `rate_limit` on auth, files served through controller (Pundit), PII filtered from logs. Soft delete (`discarded_at`) on `users` and `homologation_requests` — use `.kept` scope, never hard delete without GDPR request.
9. **Mobile-first** — Every page works at 360px+. See `docs/15_MOBILE_PATTERNS.md`.
10. **Keep it simple** — `<textarea>` not rich text, no command menu, no audit log. Dark mode is allowed (toggle in header, CSS vars in `application.css`).

## Coding Patterns (Rails + Inertia.js + React)

### 1. Centralized routes — `app/frontend/lib/routes.ts`

Full route list lives in `app/frontend/lib/routes.ts` — add new routes there, never inline.

```tsx
// ❌ <Link href={`/requests/${id}`}>  ✅ <Link href={routes.request(id)}>
// ❌ router.post(`/requests/${id}/confirm_payment`)  ✅ router.post(routes.confirmPayment(id))
```

### 2. Serialization — private `_json` methods, explicit camelCase

Never `.as_json`. Dates = ISO 8601 strings. One `_json` method = one TS interface.
```ruby
# ✅ render inertia: "Requests/Show", props: { request: request_json(@request) }
private
def request_json(r)
  { id: r.id, subject: r.subject, serviceType: r.service_type,
    status: r.status, createdAt: r.created_at.iso8601, user: user_json(r.user) }
end
```

### 3. Shared Props — `inertia_share` in ApplicationController

Keys: `auth` (user), `flash`, `features` (from `build_features`), `unreadNotificationsCount`, `selectOptions`.
Type in `app/frontend/types/index.ts` as `SharedProps extends PageProps`. Never duplicate `current_user` in page props.

### 4. Page props — one TS interface per page in `types/pages.ts`

Usage: `const { request } = usePage<SharedProps & RequestsShowProps>().props;`

### 5. Controller pattern — `authorize` → build props via `_json` methods → `render inertia:`

Conditional props by role: `props[:adminActions] = { ... } if current_user.coordinator?`

### 6. Feature flags — `build_features(user)` returns `{ canConfirmPayment:, canManageUsers:, ... }`

```tsx
// ❌ {currentUser.roles.includes('coordinator') && <Button />}
// ✅ {features.canConfirmPayment && <Button />}
```

### 7. Navigation and mutations — only Inertia

`<Link>` for links, `router.post/patch/delete` for mutations. Never `<a href>`, `fetch()`, `window.location`.
Exception: Action Cable WebSocket receives are not Inertia — that's fine.

### 8. Flash messages — always I18n

`redirect_to path, notice: t("flash.payment_confirmed")`. Key naming: `flash.{entity}_{past_tense}`.

### 9. N+1 — `.includes()` in controller, never lazy load in `_json`

`policy_scope(HomologationRequest).includes(:user, :conversation).order(updated_at: :desc)`
For lookups: `User.where(id: ids).index_by(&:id)` — one query, O(1) access.

## Testing (Minitest + FactoryBot + Faker)

- **FactoryBot + Faker** — factories in `test/factories/*.rb`. No fixtures, no mocks for ActiveRecord.
- **Every new controller action gets a test before merge.** No exceptions.
- Run `bin/rails test && npm run check` before committing.
- Full patterns, test matrix: `docs/16_TESTING.md`.
- **Parallel tests** — `parallelize(workers: :number_of_processors)` in `test_helper.rb`. All factories must be parallel-safe.

### Factory rules

1. **Emails — `sequence` + `Process.pid`, never `Faker::Internet.unique.email`.**
   `Faker.unique` tracks uniqueness per-process only — collides across parallel workers.
   ```ruby
   # ✅
   sequence(:email_address) { |n| "user#{n}_#{Process.pid}@test.example.com" }
   # ❌ Faker::Internet.unique.email
   ```

2. **Multilingual names — Faker `:ru` / `:es` + `.truncate(100)`.**
   App serves Russian- and Spanish-speaking users. Names must exercise both Cyrillic and Latin. Always truncate to model max length.
   ```ruby
   name {
     locale = %i[ru es].sample
     prev = Faker::Config.locale
     Faker::Config.locale = locale
     n = Faker::Name.name.truncate(100, omission: "")
     Faker::Config.locale = prev
     n
   }
   ```

3. **Decimal money — `rand().round(2)`, never `Faker::Commerce.price`.**
   `Faker::Commerce.price` returns Float. DB column is `decimal(10,2)`.
   ```ruby
   # ✅ payment_amount { rand(50.0..500.0).round(2) }
   # ❌ payment_amount { Faker::Commerce.price(range: 50..500.0) }
   ```

4. **HomologationRequest default is `draft`.** Always use explicit trait: `:submitted`, `:awaiting_payment`, `:payment_confirmed`, `:in_pipeline`. Never rely on bare `create(:homologation_request)`.

5. **`:with_conversation` trait does `request.reload`** before checking association — prevents double-creation when combined with `:submitted` (model callback also creates conversation).

6. **Lesson tests — always create `teacher_student` in setup before `create(:lesson)`.** The lesson factory has `after(:build)` that auto-creates a coordinator + teacher_student if missing. This breaks `User.count` / `assert_difference` assertions.
   ```ruby
   # ✅ Explicit setup
   @coordinator = create(:user, :coordinator)
   create(:teacher_student, teacher: @teacher, student: @student, assigned_by: @coordinator.id)
   @lesson = create(:lesson, teacher: @teacher, student: @student)
   # ❌ create(:lesson) without pre-existing teacher_student
   ```

7. **Time-sensitive tests — always wrap in `freeze_time`.** Never rely on `X.minutes.from_now` without freezing — causes flaky tests on slow CI.
   ```ruby
   # ✅
   freeze_time do
     @lesson.update!(scheduled_at: 60.minutes.from_now, status: "scheduled")
     LessonReminderJob.perform_now
     assert_equal 1, Notification.count
   end
   ```

8. **Action Cable in tests** — `config/cable.yml` uses `adapter: test`. Broadcasts go to in-memory adapter, not SQLite. No need to stub.


## Status Flow

`draft → submitted → in_review ⇄ awaiting_reply → awaiting_payment → payment_confirmed → in_progress → resolved/closed`

- Enforced via `@request.transition_to!("new_status", changed_by: current_user)` — invalid raises `InvalidTransition`.
- AmoCRM Lead created at `payment_confirmed`. Pre-payment statuses exist only in our app.
- Full state machine table: `docs/03_FEATURES.md`.

## Documentation

Before touching a feature area, read the relevant `docs/XX_*.md` file. Key docs: `02_DATABASE_SCHEMA`, `03_FEATURES`, `04_ROLES_AND_AUTHORIZATION`, `07_IMPLEMENTATION_PLAN`, `16_TESTING`.

## UI Standards

Reference: `shadcn-admin` by satnaing. Read existing pages before building new ones — follow the same patterns.

- **Every page:** `<AuthenticatedLayout breadcrumbs={[...]}>` → `<Main>` (or `<Main fixed>` for chat/split-pane)
- **Page title:** `text-2xl font-bold tracking-tight` + `mb-6`
- **Spacing:** `space-y-6` between sections, `space-y-4` inside cards/forms, `space-y-1.5` label→input
- **Touch targets:** ALL buttons/interactive elements: `min-h-[44px]` on mobile
- **Cards:** Always `<Card>`, never card-like `<div>`
- **Mobile-first:** Every page works at 360px+. Title+action: `flex-col` → `sm:flex-row`
- **Empty states:** Centered icon + title + hint + CTA button

## Banned Patterns

`.as_json` · `react-hook-form` · `zod` · `<a href>` · `fetch()`/`axios` · `window.location` · hardcoded URL paths · role checks in React · Tiptap · zustand · AmoCRM sync before `payment_confirmed` · skipping `authorize` · skipping tests · custom card-like `<div>` instead of `<Card>` · buttons without `min-h-[44px]` · pages without breadcrumbs · pages without `<Main>` wrapper · `Faker::Internet.unique.email` (use sequence) · `Faker::Commerce.price` (use rand().round(2)) · `X.minutes.from_now` in assertions without `freeze_time` · `create(:lesson)` without pre-existing `teacher_student` · `create(:homologation_request)` without explicit status trait · fixtures (`test/fixtures/`)
