# Database Schema

## Entity Relationship Diagram

```
┌──────────────────────┐     ┌──────────────┐     ┌────────────────────────┐
│       users           │────<│  user_roles   │>────│        roles           │
│                      │     │              │     │                        │
│ id                   │     │ user_id (FK) │     │ id                     │
│ name                 │     │ role_id (FK) │     │ name (enum-like)       │
│ email_address        │     └──────────────┘     │  - super_admin         │
│ password_digest      │                          │  - coordinator         │
│ provider             │                          │  - teacher             │
│ uid                  │                          │  - student             │
│ avatar_url           │                          │  - family              │
│ phone                │                          └────────────────────────┘
│ whatsapp             │
│ birthday             │
│ country              │
│ locale               │
│ amo_crm_contact_id   │
│ created_at           │
│ updated_at           │
└──────────┬───────────┘
           │
           │ has_many
           ▼
┌──────────────────────────────┐
│    homologation_requests      │
│                              │
│ id                           │
│ user_id (FK)                 │── belongs_to :user (student)
│ coordinator_id (FK)          │── belongs_to :coordinator, optional
│ service_type (string)        │── enum: equivalencia, invoice, informe, other
│ subject (string)             │
│ description (text)           │
│ identity_card (string)       │
│ passport (string)            │
│ education_system (string)    │
│ studies_finished (string)    │
│ study_type_spain (string)    │
│ studies_spain (string)       │
│ university (string)          │
│ country (string)             │
│ referral_source (string)     │
│ language_knowledge (string)  │
│ language_certificate (string)│
│ status (string)              │
│ privacy_accepted (boolean)   │
│ payment_amount (decimal)     │
│ payment_confirmed_at (dt)    │
│ payment_confirmed_by (FK)    │
│ amo_crm_lead_id (string)    │
│ amo_crm_synced_at (datetime) │
│ amo_crm_sync_error (text)   │
│ created_at                   │
│ updated_at                   │
└──────────┬───────────────────┘
           │
           │ has_one                    has_many_attached
           ▼                            ▼
┌─────────────────────┐      ┌─────────────────────────┐
│   conversations      │      │  Active Storage files    │
│                     │      │                         │
│ id                  │      │  :application (one)     │
│ homologation_       │      │  :originals   (many)    │
│   request_id (FK)   │      │  :documents   (many)    │
│ created_at          │      └─────────────────────────┘
│ updated_at          │
└────────┬────────────┘
         │
         │ has_many
         ▼
┌─────────────────────┐
│     messages         │
│                     │
│ id                  │
│ conversation_id (FK)│
│ user_id (FK)        │── belongs_to :user (author)
│ body (text)         │
│ created_at          │
│ updated_at          │
└─────────────────────┘
    │ has_many_attached :attachments


┌─────────────────────┐     ┌─────────────────────┐     ┌─────────────────────┐
│   notifications      │     │     sessions         │     │   amo_crm_tokens     │
│                     │     │  (Rails 8 built-in) │     │                     │
│ id                  │     │                     │     │ id                  │
│ user_id (FK)        │     │ id                  │     │ access_token (text) │
│ notifiable_type     │     │ user_id (FK)        │     │ refresh_token (text)│
│ notifiable_id       │     │ ip_address          │     │ expires_at (dt)     │
│ title (string)      │     │ user_agent          │     │ created_at          │
│ body (text)         │     │ created_at          │     │ updated_at          │
│ read_at (datetime)  │     │ updated_at          │     └─────────────────────┘
│ created_at          │     └─────────────────────┘
│ updated_at          │
└─────────────────────┘
```

## Tables Detail

### users
Profile data collected at registration. Kept minimal — only what the student knows about themselves.

| Column             | Type     | Constraints              | Notes                           |
|--------------------|----------|--------------------------|----------------------------------|
| id                 | integer  | PK, auto-increment       |                                  |
| name               | string   | NOT NULL                 | Full name                        |
| email_address      | string   | NOT NULL, UNIQUE, INDEX  | Login identifier                 |
| password_digest    | string   | NULL allowed             | NULL for OAuth-only users        |
| provider           | string   | NULL allowed             | "google" / "apple" / NULL        |
| uid                | string   | NULL allowed             | OAuth provider user ID           |
| avatar_url         | string   | NULL allowed             | Profile photo URL                |
| phone              | string   | NULL allowed             | Contact phone                    |
| whatsapp           | string   | NULL allowed             | WhatsApp number (+country code)  |
| birthday           | date     | NULL allowed             | Date of birth                    |
| country            | string   | NULL allowed             | Country of origin                |
| locale             | string   | default: "es"            | UI language (es/en/ru)           |
| amo_crm_contact_id | string   | NULL allowed, INDEX      | AmoCRM contact ID                |
| created_at         | datetime | NOT NULL                 |                                  |
| updated_at         | datetime | NOT NULL                 |                                  |

**Indexes:** `email_address` (unique), `[provider, uid]` (unique), `amo_crm_contact_id`

**Note:** `identity_card`, `passport`, `language_knowledge`, `language_certificate` moved to `homologation_requests` — they belong to a specific request context, not the user profile. A student may have different documents for different requests.

### roles

| Column | Type    | Constraints      | Notes                                              |
|--------|---------|------------------|----------------------------------------------------|
| id     | integer | PK               |                                                    |
| name   | string  | NOT NULL, UNIQUE | super_admin / coordinator / teacher / student / family |

### user_roles

| Column  | Type    | Constraints            |
|---------|---------|------------------------|
| id      | integer | PK                     |
| user_id | integer | FK → users, NOT NULL   |
| role_id | integer | FK → roles, NOT NULL   |

**Indexes:** `[user_id, role_id]` (unique)

### homologation_requests
Core business entity. Contains all data the student fills in the request form + coordinator fields.

| Column               | Type     | Constraints                    | Who fills    | Notes                                    |
|----------------------|----------|--------------------------------|--------------|------------------------------------------|
| id                   | integer  | PK                             | auto         |                                          |
| user_id              | integer  | FK → users, NOT NULL           | auto         | Student who submitted                    |
| coordinator_id       | integer  | FK → users, NULL               | coordinator  | Assigned coordinator                     |
| service_type         | string   | NOT NULL                       | student      | equivalencia / invoice / informe / other |
| subject              | string   | NOT NULL                       | student      | Short title                              |
| description          | text     | NULL                           | student      | Detailed description                     |
| identity_card        | string   | NULL                           | student      | DNI/NIE number                           |
| passport             | string   | NULL                           | student      | Passport number                          |
| education_system     | string   | NULL                           | student      | Country/system of origin                 |
| studies_finished     | string   | NULL                           | student      | Yes / No / In progress                   |
| study_type_spain     | string   | NULL                           | student      | Grado/Master/Doctorado/FP/Bachillerato  |
| studies_spain        | string   | NULL                           | student      | Specific studies name                    |
| university           | string   | NULL                           | student      | Target university in Spain               |
| country              | string   | NULL                           | student      | Country of origin (pre-filled from profile)|
| referral_source      | string   | NULL                           | student      | How they found the service               |
| language_knowledge   | string   | NULL                           | student      | Language level (A1-C2)                   |
| language_certificate | string   | NULL                           | student      | Certificate (DELE, SIELE, etc.)          |
| status               | string   | NOT NULL, default: "submitted" | system/coord | See status flow below                    |
| privacy_accepted     | boolean  | NOT NULL, default: false       | student      |                                          |
| payment_amount       | decimal  | NULL                           | coordinator  | Amount to pay (€), set in chat           |
| payment_confirmed_at | datetime | NULL                           | system       | Auto-set on confirm                      |
| payment_confirmed_by | integer  | FK → users, NULL               | system       | Coordinator who confirmed                |
| amo_crm_lead_id      | string   | NULL                           | system       | AmoCRM lead ID after sync                |
| amo_crm_synced_at    | datetime | NULL                           | system       | Last successful CRM sync                 |
| amo_crm_sync_error   | text     | NULL                           | system       | Last sync error (if any)                 |
| created_at           | datetime | NOT NULL                       | auto         |                                          |
| updated_at           | datetime | NOT NULL                       | auto         |                                          |

**Indexes:** `user_id`, `coordinator_id`, `status`, `amo_crm_lead_id`

**Active Storage attachments:**
```ruby
has_one_attached  :application     # Application form (заявление) — student uploads
has_many_attached :originals       # Original academic documents — student uploads
has_many_attached :documents       # Other documents — student uploads
# Translations and Registry — coordinator uploads LATER directly in AmoCRM, NOT in our app
```

**Status flow:**
```
submitted → in_review → awaiting_payment → payment_confirmed → in_progress → resolved
                ↓                                                                ↓
          awaiting_reply                                                       closed
```

**AmoCRM Lead created ONLY on `payment_confirmed`** (coordinator clicks "Confirm Payment").

### conversations

| Column                  | Type     | Constraints                        |
|-------------------------|----------|------------------------------------|
| id                      | integer  | PK                                 |
| homologation_request_id | integer  | FK → homologation_requests, UNIQUE |
| created_at              | datetime | NOT NULL                           |
| updated_at              | datetime | NOT NULL                           |

### messages

| Column          | Type     | Constraints                      |
|-----------------|----------|----------------------------------|
| id              | integer  | PK                               |
| conversation_id | integer  | FK → conversations, NOT NULL     |
| user_id         | integer  | FK → users, NOT NULL             |
| body            | text     | NOT NULL                         |
| created_at      | datetime | NOT NULL                         |
| updated_at      | datetime | NOT NULL                         |

**Active Storage:** `has_many_attached :attachments`
**Indexes:** `conversation_id`, `[conversation_id, created_at]`

### notifications

| Column          | Type     | Constraints          |
|-----------------|----------|----------------------|
| id              | integer  | PK                   |
| user_id         | integer  | FK → users, NOT NULL |
| notifiable_type | string   | NOT NULL             |
| notifiable_id   | integer  | NOT NULL             |
| title           | string   | NOT NULL             |
| body            | text     | NULL                 |
| read_at         | datetime | NULL                 |
| created_at      | datetime | NOT NULL             |
| updated_at      | datetime | NOT NULL             |

**Indexes:** `user_id`, `[notifiable_type, notifiable_id]`, `[user_id, read_at]`

### amo_crm_tokens
OAuth2 token storage for AmoCRM API. Only one active row.

| Column        | Type     | Constraints | Notes                        |
|---------------|----------|-------------|------------------------------|
| id            | integer  | PK          |                              |
| access_token  | text     | NOT NULL    | Current access token         |
| refresh_token | text     | NOT NULL    | For refreshing expired token |
| expires_at    | datetime | NOT NULL    | When access_token expires    |
| created_at    | datetime | NOT NULL    |                              |
| updated_at    | datetime | NOT NULL    |                              |

## Seeds

```ruby
# db/seeds.rb
%w[super_admin coordinator teacher student family].each do |role_name|
  Role.find_or_create_by!(name: role_name)
end
```
