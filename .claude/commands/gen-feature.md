# Generate Feature

Feature: $ARGUMENTS

## Before coding

1. Read the relevant docs from the "Documentation — When to Read What" table in CLAUDE.md (only the ones needed for this feature, not all).
2. Create a plan covering: migrations, Pundit policy, controller actions, routes (Rails + `routes.ts`), TS types, React pages, i18n keys (es/en/ru), fixtures and tests.
3. Present the plan and **wait for approval** before writing code.

## Implementation order

Build in this exact sequence — never skip ahead:

1. **Migration + Model** — validations, associations, scopes, fixtures
2. **Pundit policy** — every action authorized, Scope defined
3. **Controller** — authorize → `_json` props → `render inertia:`
4. **Routes** — `config/routes.rb` + `app/frontend/lib/routes.ts`
5. **TypeScript types** — interface in `types/pages.ts` mirroring `_json`
6. **React page** — shadcn/ui, `useForm`, `t()`, `routes.*`, `features.*`, mobile-first
7. **i18n** — keys in all 3 languages (frontend + Rails if flash/mailers)
8. **Tests** — controller integration tests, fixtures only
9. **Verify** — `bin/rails test && npm run check`

All rules and patterns are in CLAUDE.md — follow them strictly.
