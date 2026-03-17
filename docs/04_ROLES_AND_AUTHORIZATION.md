# 04. Roles, Authorization & Workflows

> Complete reference: role definitions, permission matrix, user workflows, notification strategy, and technical implementation.

---

## Role Overview

| Role | Purpose | Created by | Landing page |
|------|---------|------------|--------------|
| **Super Admin** | Full system control: homologation requests, payments, AmoCRM, billing, user management | Seeded / manual | `/` (dashboard) |
| **Coordinator** | Manages teachers and student assignments; does NOT handle homologation requests | Super Admin via Admin panel | `/teachers` |
| **Teacher** | Gives Spanish lessons, manages calendar, chats with assigned students | Super Admin/Coordinator via Admin panel | `/calendar` |
| **Student** | Submits homologation requests, uploads documents, chats, attends lessons | Self-registers (email or OAuth) | `/` (dashboard) |

---

## Permission Matrix

| Action | Super Admin | Coordinator | Teacher | Student |
|--------|:-----------:|:-----------:|:-------:|:-------:|
| **Administration** | | | | |
| Admin dashboard | ✅ | — | — | — |
| Manage users (CRUD) | ✅ | — | — | — |
| Stripe billing | ✅ | — | — | — |
| Set teacher level / rate | ✅ | — | — | — |
| **Homologation & Documents** | | | | |
| View all requests | ✅ | — | — | — |
| View own requests | ✅ | — | — | ✅ |
| Submit new request | — | — | — | ✅ |
| Change request status | ✅ | — | — | — |
| Confirm payment → AmoCRM sync | ✅ | — | — | — |
| Upload documents | ✅ | — | — | ✅ |
| Download all documents | ✅ | — | — | — |
| Download own documents | ✅ | — | — | ✅ |
| Retry AmoCRM sync | ✅ | — | — | — |
| **Teachers & Lessons** | | | | |
| Assign teacher to student | ✅ | ✅ | — | — |
| Remove student from teacher | ✅ | ✅ | — | — |
| View teacher calendar | ✅ | ✅ | ✅ | — |
| View all lessons | ✅ | ✅ | — | — |
| View own lessons | — | — | ✅ | ✅ |
| Create / edit / cancel lessons | ✅ | ✅ | ✅ | — |
| **Chat** | | | | |
| Chat in request conversation | ✅ | — | — | ✅ |
| Chat teacher ↔ student | ✅ | ✅ | ✅ | ✅ |
| Inbox: all chats (/chats) | ✅ | — | — | — |

---

## Navigation by Role

### Student

| Page | Route | Purpose |
|------|-------|---------|
| Dashboard | `/` | Summary stats: total requests, pending requests |
| My Requests | `/requests` | List of own requests with status filters |
| New Request | `/requests/new` | Form to create a homologation request |
| Request Detail | `/requests/:id` | View request + embedded chat with super admin |
| My Chats | `/conversations` | List of all conversations (request + teacher) |
| My Lessons | `/lessons` | Upcoming and past lessons with meeting links |
| Notifications | `/notifications` | All notifications |
| Profile | `/profile` | Personal settings |

### Coordinator

| Page | Route | Purpose |
|------|-------|---------|
| Teachers (landing) | `/teachers` | Manage teachers, assign/remove students |
| All Lessons | `/lessons` | Overview table of all lessons |
| My Chats | `/conversations` | Teacher-student conversations they participate in |
| Notifications | `/notifications` | All notifications |
| Profile | `/profile` | Personal settings |

**NOT visible:** Dashboard, All Requests, Inbox (/chats), Admin panel.

### Teacher

| Page | Route | Purpose |
|------|-------|---------|
| Calendar (landing) | `/calendar` | Weekly calendar with lesson slots |
| My Chats | `/conversations` | Conversations with assigned students |
| Notifications | `/notifications` | Lesson reminders, new messages |
| Profile | `/profile` | Personal settings, permanent meeting link |

### Super Admin

All pages from all roles, plus:

| Page | Route | Purpose |
|------|-------|---------|
| Dashboard | `/` | Stats: requests, users, trends, charts |
| All Requests | `/requests` | All homologation requests with filters |
| Inbox (Chats) | `/chats` | Unified chat inbox: request + teacher-student |
| Admin Dashboard | `/admin` | System-wide stats, charts, AmoCRM status |
| User Management | `/admin/users` | CRUD all users, assign/remove roles |

---

## Workflows

### Student: Submit a Homologation Request

```
1. Clicks "New Request"
2. Fills form: subject, service type, education system, university, etc.
3. Uploads documents (3 categories):
   - Application (1 file) — official diploma
   - Originals (many) — transcript pages
   - Documents (many) — certified translations
4. Saves as Draft or Submits directly
5. On Submit:
   → Status changes to "submitted"
   → Conversation auto-created with student as participant
   → Super admin receives notification
6. Student waits for review
```

### Student: Respond in Chat

```
1. Receives notification: "New message from [Super Admin]"
2. Opens request detail → embedded chat, or /conversations
3. Reads questions, types reply
4. Message delivered in real-time via Action Cable
5. Super admin sees instantly (if online) or gets email digest in 10 min
```

### Student: Attend a Lesson

```
1. Coordinator assigns student to teacher → notification
2. Teacher schedules lesson → notification
3. Opens /lessons → sees upcoming lesson with date, time, teacher name
4. 1 hour before → reminder notification
5. Clicks meeting link → joins video call
6. After lesson → teacher marks "completed"
```

### Coordinator: Manage Teachers & Assign Students

```
1. Opens /teachers (landing page after login)
2. Sees teacher cards: name, level, rate, student count, lessons this week
3. To assign a student:
   a. Clicks "Assign Student" on a teacher card
   b. Selects student → clicks "Assign"
   c. System creates TeacherStudent link + Conversation
   d. Teacher and student get notifications
4. To remove: clicks student → "Remove"
```

### Coordinator: Monitor Lessons

```
1. Opens /lessons → all lessons across all teachers
2. Can filter by teacher, student, status, date range
3. Can create/edit/cancel lessons for any teacher-student pair
```

### Super Admin: Review a Request

```
1. Receives notification: "New request from [Student]"
2. Opens /requests → filters by "submitted"
3. Clicks request → full detail + embedded chat + status controls
4. Reviews documents:
   - If incomplete → status "awaiting_reply" + chat message
   - If OK → status "in_review"
5. When review complete → status "awaiting_payment"
```

### Super Admin: Confirm Payment & Sync to AmoCRM

```
1. Student pays externally (bank transfer, Bizum, etc.)
2. Opens request (status: "awaiting_payment")
3. Clicks "Confirm Payment" → enters amount (€) → "Confirm & Sync"
   → Status → "payment_confirmed"
   → AmoCrmSyncJob enqueued (Contact + Lead + files)
   → Student notified
4. Status → "in_progress" → "resolved"
```

### Super Admin: System Administration

```
1. /admin → system-wide dashboard (stats, charts, failed syncs)
2. /admin/users → create/edit/deactivate users, assign roles
3. /chats → unified inbox of ALL conversations
4. /teachers → same as coordinator (assign students, manage)
```

### Teacher: Daily Routine

```
1. Opens app → lands on /calendar (weekly view)
2. Sees lessons: student name, time, meeting link status
3. Before lesson: adds meeting link (Zoom, Meet) via edit dialog
4. Teaches via meeting link
5. After lesson: marks "completed"
```

### Teacher: Schedule a Lesson

```
1. Opens /calendar → clicks time slot or "New Lesson"
2. Selects student, date/time, duration, meeting link, notes
3. Saves → student gets notification
4. 1 hour before → both get reminder
```

---

## Request Status Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    REQUEST LIFECYCLE                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  [Student]                                                      │
│  Creates request → saves as DRAFT                               │
│       │                                                         │
│       ▼                                                         │
│  Submits → SUBMITTED                                            │
│       │    (conversation auto-created)                          │
│       │    (super admin notified)                               │
│       │                                                         │
│  [Super Admin]                                                  │
│       │                                                         │
│       ▼                                                         │
│  Reviews → IN_REVIEW                                            │
│       │                                                         │
│       ├──── needs info ──→ AWAITING_REPLY                       │
│       │                      │  (student notified)              │
│       │                      │  student replies in chat         │
│       │    ◄─────────────────┘  super admin moves back          │
│       │                                                         │
│       ▼                                                         │
│  Documents OK → AWAITING_PAYMENT                                │
│       │           (student notified)                            │
│       │           student pays externally                       │
│       │                                                         │
│       ▼                                                         │
│  Confirms payment → PAYMENT_CONFIRMED                           │
│       │               (AmoCRM sync triggered)                   │
│       │               (student notified)                        │
│       │                                                         │
│       ▼                                                         │
│  Processing → IN_PROGRESS                                       │
│       │                                                         │
│       ▼                                                         │
│  Done → RESOLVED  or  CLOSED                                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## How Users Find Each Other

There is **no "start new chat" button**. Conversations are created automatically:

| Trigger | Conversation Type | Participants | Who initiates |
|---------|-------------------|-------------|---------------|
| Student submits request | Request chat | Student + Super Admin(s) | Student (by submitting) |
| Coordinator assigns student to teacher | Teacher-student chat | Teacher + Student | Coordinator |

| Role | How they discover conversations |
|------|-------------------------------|
| **Student** | Request detail page (embedded chat) or `/conversations` list |
| **Super Admin** | `/chats` inbox (all conversations) or request detail page |
| **Coordinator** | `/conversations` list (teacher-student chats they participate in) |
| **Teacher** | `/conversations` list (only their assigned students) |

---

## Notification Strategy

| Event | Who gets notified | Channels |
|-------|-------------------|----------|
| New request submitted | All super admins | In-app, Email (immediate) |
| New chat message | Other conversation participants | In-app, Email (10min digest), Telegram |
| Request status changed | Request owner (student) | In-app, Email (immediate) |
| Payment confirmed | Request owner (student) | In-app, Email (immediate) |
| Student assigned to teacher | Teacher + Student | In-app, Email (immediate) |
| Lesson scheduled | Student | In-app, Email (immediate) |
| Lesson cancelled | Student | In-app, Email (immediate) |
| Lesson starts in 1 hour | Teacher + Student | In-app, Email (immediate) |
| AmoCRM sync failed | Super admin who confirmed | In-app |

### Email Strategy

- **System events** (status changes, payments, lessons): Email sent immediately
- **Chat messages**: Email delayed 10 minutes. If user reads before then, email is skipped. Multiple messages in 10 min = one digest email.
- **User control**: Each user can toggle email and Telegram notifications in profile settings.

---

## Technical Implementation

### User Model

```ruby
class User < ApplicationRecord
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_one :teacher_profile, dependent: :destroy

  has_many :teacher_student_links, class_name: "TeacherStudent", foreign_key: :teacher_id
  has_many :students, through: :teacher_student_links, source: :student
  has_many :student_teacher_links, class_name: "TeacherStudent", foreign_key: :student_id
  has_many :teachers, through: :student_teacher_links, source: :teacher

  has_many :taught_lessons, class_name: "Lesson", foreign_key: :teacher_id
  has_many :booked_lessons, class_name: "Lesson", foreign_key: :student_id

  def super_admin? = has_role?("super_admin")
  def coordinator? = has_role?("coordinator")
  def teacher?     = has_role?("teacher")
  def student?     = has_role?("student")

  private

  def has_role?(name) = roles.exists?(name: name)
end
```

### Feature Flags — `ApplicationController#build_features`

```ruby
{
  canConfirmPayment: user.super_admin?,
  canManageUsers: user.super_admin?,
  canManageTeachers: user.coordinator? || user.super_admin?,
  canAccessChats: user.super_admin?,
  canAccessAdmin: user.super_admin?,
  canCreateRequest: user.student?,
  canCreateLesson: user.teacher? || user.coordinator? || user.super_admin?,

  canSeeDashboard: user.super_admin? || user.student?,
  canSeeAllRequests: user.super_admin?,
  canSeeMyRequests: user.student?,
  canSeeAllLessons: user.coordinator? || user.super_admin?,
  canSeeCalendar: user.teacher?,
  canSeeMyLessons: user.student?,
  canSeeChat: user.teacher? || user.student?
}
```

### Frontend Authorization — Feature Flags Only

**IMPORTANT:** Never check roles directly in React. Use `features.*` flags:

```tsx
// WRONG — role check in React (BANNED)
{currentUser.roles.includes('coordinator') && <Button />}

// CORRECT — feature flag
const { features } = usePage<SharedProps>().props
{features.canConfirmPayment && <Button />}
```

### Security & Data Access Rules

1. **Pundit policies** enforce authorization on every controller action (`authorize` + `after_action :verify_authorized`)
2. **Scope filtering** — students see own data, teachers see own students, super admin sees all
3. **Coordinators** see only teacher/lesson data, never homologation requests
4. **PII fields** encrypted at rest (`encrypts` on sensitive User fields)
5. **Soft delete** via `discarded_at` — never hard-delete without GDPR request
6. **Files served through controller** — Pundit checks on every download
7. **Rate limiting** on authentication endpoints
