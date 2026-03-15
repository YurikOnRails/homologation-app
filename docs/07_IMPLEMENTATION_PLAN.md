# Implementation Plan

## Phase 1: Foundation (Steps 1-5)

### Step 1: Authentication + Profile
```bash
bin/rails generate authentication
```
Then:
- Extend User model: add `name`, `provider`, `uid`, `avatar_url`, `phone`, `whatsapp`, `birthday`, `country`, `locale`, `amo_crm_contact_id`
- Add gems: `omniauth`, `omniauth-google-oauth2`, `omniauth-apple`, `omniauth-rails_csrf_protection`
- Create `Auth::OmniauthCallbacksController`
- Create React pages: `auth/Login.tsx`, `auth/Register.tsx`, `auth/ForgotPassword.tsx`
- Create `profile/Complete.tsx` — shown after first login (WhatsApp, Phone, Birthday, Country)
- Configure Inertia shared data for `current_user`
- Write tests for signup, login, OAuth flow, profile completion

### Step 2: Roles & Authorization
```bash
bin/rails generate model Role name:string
bin/rails generate model UserRole user:references role:references
bundle add pundit
bin/rails generate pundit:install
```
Then:
- Add role associations to User
- Add role helper methods (`super_admin?`, `coordinator?`, etc.)
- Seed roles in `db/seeds.rb`
- Create base `ApplicationPolicy`
- Add Pundit to `InertiaController`
- Create `RoleGuard` React component
- Write tests for role checks

### Step 3: Homologation Requests
```bash
bin/rails generate model HomologationRequest \
  user:references subject:string description:text \
  service_type:string identity_card:string passport:string \
  education_system:string studies_finished:string \
  study_type_spain:string studies_spain:string university:string \
  country:string referral_source:string \
  language_knowledge:string language_certificate:string \
  status:string privacy_accepted:boolean \
  payment_amount:decimal \
  amo_crm_lead_id:string amo_crm_synced_at:datetime amo_crm_sync_error:text
```
Then:
- Add `coordinator_id`, `payment_confirmed_at`, `payment_confirmed_by` columns
- Add status enum, validations, scopes
- Configure Active Storage:
  - `has_one_attached :application`
  - `has_many_attached :originals`
  - `has_many_attached :documents`
- Create `HomologationRequestsController` (index, show, new, create, update)
- Create `HomologationRequestPolicy`
- Create React pages: `requests/Index.tsx`, `requests/New.tsx`, `requests/Show.tsx`
- Build `RequestForm` component (12 fields, grouped into sections)
- Build `FileDropZone` component (drag & drop, categorized uploads)
- Build `RequestTable` component with search and filter
- Write tests for CRUD and authorization

### Step 4: Chat System
```bash
bin/rails generate model Conversation homologation_request:references
bin/rails generate model Message conversation:references user:references body:text
bin/rails generate channel Conversation
```
Then:
- Auto-create Conversation when HomologationRequest is created
- `ConversationChannel` — subscribe to specific conversation
- Broadcast new messages via Action Cable
- Create `ChatWindow`, `MessageBubble`, `MessageInput` components
- Add message file attachments via Active Storage
- Integrate chat into `requests/Show.tsx` (left panel)
- Write tests for message creation and broadcasting

### Step 5: Notifications
```bash
bin/rails generate model Notification user:references \
  notifiable:references{polymorphic} title:string body:text read_at:datetime
bin/rails generate channel Notification
```
Then:
- Create `NotificationChannel` (per-user)
- `NotificationJob` — sends in-app + email
- `RequestMailer` for email notifications
- Bell icon component with unread count (via Inertia shared data)
- Notification dropdown panel
- Mark as read functionality
- Write tests

---

## Phase 2: Admin & CRM (Steps 6-7)

### Step 6: Admin Dashboard
- Create `Admin::DashboardController` with stats aggregations
- Create `Admin::UsersController` (CRUD for coordinators/teachers)
- Create admin policies (super_admin only)
- Install `recharts` for charts
- Build React pages:
  - `admin/Dashboard.tsx` — stats cards + charts
  - `admin/Users.tsx` — user management table
- Charts: requests over time, status distribution, response times
- Write tests

### Step 7: AmoCRM Integration
```bash
bin/rails generate model AmoCrmToken access_token:text refresh_token:text expires_at:datetime
```
Then:
- Create `AmoCrmClient` service (Contact + Lead API)
- Create `AmoCrmSyncJob` (triggered on payment confirmation)
- Add `confirm_payment` action to HomologationRequestsController
- Build "Confirm Payment" dialog (coordinator enters Sale €)
- CRM sync status indicator on request detail page
- Admin panel: sync status, errors, retry
- **What syncs automatically:** Contact (name, email, phone, WhatsApp, birthday, country, age), Lead (service, university, description, sale, date, files)
- **What stays manual in AmoCRM:** Translations, Registry, Teachers, Comments, Reasons for refusal
- Store tokens in DB (`amo_crm_tokens` table)
- Write tests (mock API calls with WebMock)

---

## Phase 3: Polish (Steps 8-10)

### Step 8: UI/UX Setup with shadcn/ui
```bash
npx shadcn@latest init
npx shadcn@latest add button input select card dialog table badge avatar \
  dropdown-menu separator tabs textarea label checkbox command popover \
  sheet sidebar navigation-menu toast sonner form
```
**Note:** shadcn/ui should be set up early (Step 1) and components added as needed throughout.

### Step 9: Multi-language (i18n)
- Configure Rails I18n (es, en, ru)
- Add `react-i18next` to frontend
- Translate all UI strings
- Language switcher in navbar

### Step 10: Profile & Settings
- Profile edit page (name, email, phone, whatsapp, birthday, country, avatar)
- Password change
- OAuth provider linking

---

## Gems to Add

```ruby
# Gemfile additions

# Authentication (OAuth)
gem "omniauth"
gem "omniauth-google-oauth2"
gem "omniauth-apple"
gem "omniauth-rails_csrf_protection"

# Authorization
gem "pundit"

# HTTP client for AmoCRM (cleaner than Net::HTTP)
# Optional: gem "faraday" — or stick with Net::HTTP to keep deps minimal

# Testing
# gem "webmock" — for mocking AmoCRM API calls in tests
```

## NPM Packages to Add

```bash
# shadcn/ui prerequisites
npm install class-variance-authority clsx tailwind-merge lucide-react
npm install @radix-ui/react-slot

# Rich text editor for description field
npm install @tiptap/react @tiptap/starter-kit @tiptap/extension-placeholder

# Charts for admin dashboard
npm install recharts

# File upload
npm install react-dropzone

# Date formatting
npm install date-fns

# i18n (Phase 3)
npm install react-i18next i18next
```

## Test Strategy (Minitest)

```
test/
├── models/
│   ├── user_test.rb
│   ├── homologation_request_test.rb
│   ├── message_test.rb
│   └── notification_test.rb
├── controllers/
│   ├── sessions_controller_test.rb
│   ├── registrations_controller_test.rb
│   ├── homologation_requests_controller_test.rb
│   ├── messages_controller_test.rb
│   └── admin/
│       ├── dashboard_controller_test.rb
│       └── users_controller_test.rb
├── policies/
│   ├── homologation_request_policy_test.rb
│   ├── message_policy_test.rb
│   └── user_policy_test.rb
├── services/
│   └── amo_crm_client_test.rb
├── jobs/
│   ├── amo_crm_sync_job_test.rb
│   └── notification_job_test.rb
├── system/
│   ├── login_test.rb
│   ├── submit_request_test.rb
│   └── chat_test.rb
└── test_helper.rb
```

## Run Order

1. Setup shadcn/ui + base layouts
2. `bin/rails generate authentication` → extend User → OAuth → profile completion
3. Roles + Pundit + seeds
4. HomologationRequest model + controller + React pages (form + table)
5. Conversation + Messages + Action Cable
6. Notifications
7. Admin dashboard
8. AmoCRM integration (Confirm Payment → sync)
9. Polish & i18n
