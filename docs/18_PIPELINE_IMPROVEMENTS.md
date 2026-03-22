# Pipeline UI/UX Improvements

> Based on comparison of old Express app (`_reference/`) with current Rails+React implementation.
> Reference: old app source in `_reference/src/` and `_reference/server/`.

## Critical

### 1. Call `enter_pipeline!` on payment confirmation
**File:** `app/controllers/homologation_requests_controller.rb` → `confirm_payment`
**What:** After `transition_to!("payment_confirmed")`, call `@request.enter_pipeline!` to initialize pipeline fields (stage, year, checklist).
**Why:** Without this, pipeline board stays empty — cards never appear.

## High Priority (UX)

### 2. Clickable document tags on card
**Files:** `app/frontend/components/pipeline/PipelineCard.tsx`, `DocumentTags.tsx`
**What:** Each SOL/VOL/TAS/etc. tag should toggle on click via `router.patch(routes.admin.pipelineUpdate(card.id), { document_checklist: { [key]: !current } })`. No need to open CardEditDialog just to toggle one doc.
**Reference:** `_reference/src/App.jsx` — `toggleDoc()` function, each tag is a `<button>`.

### 3. Smart labels on Advance button
**Files:** `app/models/homologation_request.rb`, `app/controllers/admin/pipeline_controller.rb`, `PipelineCard.tsx`
**What:** Instead of generic "Avanzar →", show next stage name: "→ Trad.", "→ Tasas", "→ RedSARA", "✓ Fin".
**How:** Add `nextStageName` to `pipeline_card_json` from `compute_next_stage`. Display in button text.
**Reference:** `_reference/src/App.jsx` — `getAdvanceLabel()` function.

### 4. Stage icons in column headers
**File:** `app/frontend/components/pipeline/constants.ts`, `KanbanColumn.tsx`
**What:** Add emoji icons per stage: pago=€, documentos=📄, traduccion=🌐, tasas=📋, redsara=📡.
**How:** Add `icon` field to `STAGE_COLORS` constant, render in `KanbanColumn` header next to dot.
**Reference:** `_reference/src/App.jsx` — `STAGES` config object.

### 5. Restore document count (5/10)
**File:** `app/frontend/components/pipeline/DocumentTags.tsx`
**What:** Show `{complete}/{total}` after the tag row. Was removed during UI refactor.
**Reference:** `_reference/src/App.jsx` — document count shown below tags on every card.

### 6. Asymmetric action buttons
**File:** `app/frontend/components/pipeline/PipelineCard.tsx`
**What:** Retreat button should be narrow (`w-10`), Advance button should be wide (`flex-1`). Currently both are `flex-1`.
**Reference:** `_reference/src/App.jsx` — retreat is `flex: 1`, advance is `flex: 2`.

## Medium Priority (Visual Polish)

### 7. Identity card / passport on card
**Files:** `app/controllers/admin/pipeline_controller.rb` → `pipeline_card_json`, `PipelineCard.tsx`, `types/pages.ts`
**What:** Show student's identity card number (gray, monospace) below name. Add `identityCard` field to serializer.
**Reference:** `_reference/src/App.jsx` — passport shown as `#passport` in gray mono font.

### 8. Translation required indicator
**Files:** `app/controllers/admin/pipeline_controller.rb` → `pipeline_card_json`, `PipelineCard.tsx`, `types/pages.ts`
**What:** Show 🌐 badge on card if student's country requires sworn translation.
**How:** Add `requiresTranslation` boolean to serializer from `requires_translation?` model method.
**Reference:** `_reference/src/App.jsx` — `needsTr()` function, shows globe badge.

### 9. Dynamic year colors
**File:** `app/frontend/components/pipeline/PipelineCard.tsx`
**What:** Different badge color per year. Current year = amber/yellow, previous year = indigo/blue.
**Reference:** `_reference/src/App.jsx` — 2025=#6366F1 (indigo), 2026=#F59E0B (amber).

### 10. Subtitles for horizontal groups
**Files:** `app/frontend/locales/{es,en,ru}.json`, `HorizontalGroup.tsx`
**What:** Show explanatory subtitle under cotejo group titles:
- Ministerio: "No-UE sin convenio" / "Non-EU without treaty"
- Delegación: "LATAM · EAU · Convenio" / "LATAM · UAE · Treaty"
**Reference:** `_reference/src/App.jsx` — subtitles rendered under section headers.

## Low Priority / Not Needed

### 11. Flow legend visualization
**What:** Visual pipeline flow diagram: `€ → 📄 → 🌐? → 📋 → 📡 ⤵ (🏛 ó 🏢) → ✓`
**Status:** Nice-to-have, not essential. Could be a collapsible help section.

### 12. Client number (#num)
**What:** Old app had auto-generated numbers like `#26-1`, `#EQ-1`.
**Status:** Not needed — new app uses `id` and `subject` fields which serve the same purpose.

### 13. Delete button on card
**What:** Old app had ✕ button to delete clients.
**Status:** Not needed — new app uses soft delete (discarded_at) via admin/users interface.

### 14. Create button on pipeline
**What:** Old app had "+ Nuevo" button to create clients directly.
**Status:** Not needed — new app pipeline is populated automatically via registration → request → payment flow.

### 15. Audit log for pipeline
**What:** Old app logged all stage changes to audit_log table.
**Status:** Separate task. Can be added later with PaperTrail gem or custom audit table.
