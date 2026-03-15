# Review PR

Review code changes against the project's rules and patterns.

## Input

PR number or branch: $ARGUMENTS

## Step 1 — Gather changes

If a PR number is given, run `gh pr diff $ARGUMENTS`. Otherwise, run `git diff main...HEAD` to see changes on the current branch.

Read all changed files fully — do not review partial diffs without context.

## Step 2 — Check against rules

Review every changed file against these checklists:

### Rails controllers
- [ ] Every action calls `authorize` (Pundit)
- [ ] `after_action :verify_authorized` present
- [ ] Serialization via private `_json` methods with explicit camelCase (no `.as_json`)
- [ ] Dates as ISO 8601 strings in `_json` methods
- [ ] `.includes()` in controller to prevent N+1 (no lazy loading in `_json`)
- [ ] Flash messages via `t("flash.entity_action")` — no hardcoded strings
- [ ] No AmoCRM sync before `payment_confirmed` status

### Rails models
- [ ] Validations present for required fields
- [ ] `encrypts` on PII fields (phone, whatsapp, identity_card, passport)
- [ ] Status transitions via `transition_to!` if applicable
- [ ] Associations and scopes correct

### React pages/components
- [ ] All visible text via `t()` from react-i18next — no hardcoded strings
- [ ] Forms use `useForm()` from Inertia only (no zod, no react-hook-form)
- [ ] Links use `<Link>` from Inertia (no `<a href>`)
- [ ] Mutations use `router.post/patch/delete` (no `fetch()`, no `axios`, no `window.location`)
- [ ] Routes from `routes.*` in `lib/routes.ts` (no hardcoded URL paths)
- [ ] Feature flags via `features.*` from shared props (no role checks in components)
- [ ] Props typed via `usePage<SharedProps & PageProps>().props`
- [ ] Mobile-first responsive: base = mobile, `md:` tablet, `lg:` desktop
- [ ] Touch targets min 44px height on mobile
- [ ] Tables have card/list alternative on mobile (`md:hidden` / `hidden md:block`)

### TypeScript types
- [ ] Page props interface in `types/pages.ts` mirrors controller `_json` output
- [ ] SharedProps not duplicated in page props

### Routes
- [ ] New Rails routes added to `config/routes.rb`
- [ ] Matching frontend routes added to `app/frontend/lib/routes.ts`

### i18n
- [ ] New keys added in all 3 languages (es, en, ru) — frontend and Rails
- [ ] No missing translation keys

### Tests
- [ ] Every new controller action has a test
- [ ] Fixtures used (no FactoryBot, no ActiveRecord mocks)
- [ ] Tests check: HTTP status, Inertia component name, authorization, redirects

### Security
- [ ] No SQL injection, XSS, or command injection
- [ ] Files served through controller with Pundit authorization
- [ ] PII fields filtered from logs
- [ ] `rate_limit` on auth endpoints

### Forbidden patterns
- [ ] No `.as_json` in controllers
- [ ] No `react-hook-form`, `zod`, or external form libraries
- [ ] No `@tanstack/react-table`, Tiptap, zustand
- [ ] No rich text editors (only `<textarea>`)
- [ ] No dark mode
- [ ] No `fetch()`/`axios` for mutations

## Step 3 — Output

Format your review as:

### Summary
One paragraph: what this PR does and overall quality.

### Issues (must fix)
Numbered list of rule violations or bugs. For each:
- File and line number
- What's wrong
- How to fix it

### Suggestions (nice to have)
Numbered list of non-blocking improvements.

### Verdict
- **APPROVE** — no issues found, follows all patterns
- **REQUEST CHANGES** — issues found that must be fixed before merge
