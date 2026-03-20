## Task: Implement Step $ARGUMENTS (Autonomous TDD Mode)

### Phase 0 — Pre-flight

Run these checks. If any fails — STOP COMPLETELY, output the error, do not proceed:
```bash
git status              # Must be clean. If not → "STOP: commit previous work first"
bin/rails test          # Must be 0 failures. If not → "STOP: pre-existing failures"
npm run check           # Must be 0 errors. If not → "STOP: pre-existing TS errors"
```

Then read (in this order):
1. @CLAUDE.md
2. @docs/07_IMPLEMENTATION_PLAN.md — Step $ARGUMENTS section only
3. Every doc file listed in that step's context/deps section

---

### Phase 1 — TDD Implementation

**The only allowed execution order:**
```
WRITE TEST → run test (expect RED) → WRITE IMPLEMENTATION → run test (expect GREEN) → npm run check → checkpoint → next
```

**Rules:**
- Test file created BEFORE implementation file. Always.
- After writing test: run `bin/rails test path/to/specific_test.rb` — must see failure
- After writing implementation: run same command — must see green
- If test is still red after 2 fix attempts → STOP (see "On failure" below)
- Never skip a test. Never reorder pairs. Never batch multiple implementations without testing.

**After each GREEN, print one checkpoint line:**
```
✅ [test_method_name] — [files touched]
```

**On failure after 2 attempts:**
```
NEEDS_REVIEW
Step: $ARGUMENTS
Test: [method name]
Error: [exact error]
Attempts: [what you tried]
```
Stop completely. Do not touch another file.

**On business logic ambiguity:**
```
NEEDS_CLARIFICATION  
Step: $ARGUMENTS
Question: [specific question]
Options: [A vs B]
```
Stop completely. Do not guess.

---

### Phase 2 — Self Review (runs automatically after all tests green)

After all GREEN checkpoints, before declaring done — review your own work.

Run `git diff main...HEAD` and check every changed file against these rules:

**Rails controllers:**
- [ ] Every action calls `authorize`
- [ ] `after_action :verify_authorized` present
- [ ] No `.as_json` — private `_json` methods with camelCase only
- [ ] Dates as ISO 8601 in `_json`
- [ ] `.includes()` in controller, never in `_json`
- [ ] Flash via `t("flash.entity_action")` — no hardcoded strings
- [ ] No AmoCRM sync before `payment_confirmed`

**Rails models:**
- [ ] Validations on required fields
- [ ] `encrypts` on PII (phone, whatsapp, identity_card, passport)
- [ ] Status transitions via `transition_to!`

**React pages/components:**
- [ ] All visible text via `t()` — no hardcoded strings
- [ ] `useForm()` only — no zod, no react-hook-form
- [ ] `<Link>` only — no `<a href>`
- [ ] `router.post/patch/delete` only — no fetch(), axios, window.location
- [ ] `routes.*` only — no hardcoded URL strings
- [ ] `features.*` only — no role checks in components
- [ ] Props typed via `usePage<SharedProps & PageProps>().props`
- [ ] Mobile-first: base=mobile, `md:` tablet, `lg:` desktop
- [ ] Touch targets min 44px
- [ ] Tables: `hidden md:block` table + `md:hidden` card alternative

**i18n:**
- [ ] New keys added in all 3 locale files (es, en, ru)
- [ ] Rails locale files updated too

**Routes:**
- [ ] `config/routes.rb` updated
- [ ] `app/frontend/lib/routes.ts` updated

**Tests:**
- [ ] Every new controller action has a test
- [ ] Fixtures only — no FactoryBot

If any violation found → fix it immediately, re-run affected tests, re-run `npm run check`.

---

### Phase 3 — Final Verification

Run every command from the step's "Done criteria" section. Show actual output:
```bash
bin/rails test                    # Full suite — show summary line
npm run check                     # Show output
```

Then run any step-specific commands listed in Done criteria.

---

### Completion Report

Output this exact format when done:
```
## Step $ARGUMENTS — COMPLETE ✅

### Stats
- Tests written: N
- Files created: N  
- Files modified: N

### Created files:
- path/to/file.rb
- path/to/file.tsx

### Modified files:
- path/to/file.rb

### Done criteria:
- [x] criterion text → PASS (output: ...)
- [x] criterion text → PASS (output: ...)

### Self-review result: CLEAN (no violations found)
OR
### Self-review fixed: [list what was fixed]

### Decisions made (review these):
- [any non-obvious choice — explain why]

### Next step:
git add -A && git commit -m "feat: implement step $ARGUMENTS"
Then run: /build-step [N+1]
```
