# UI Components & Pages

## UI Library: shadcn/ui + Tailwind CSS

### Setup
```bash
npx shadcn@latest init
# Framework: Vite
# Style: Default
# Base color: Slate (or Neutral)
# CSS path: app/frontend/entrypoints/application.css
# Tailwind config: tailwind.config.ts (if needed, or use CSS-based config)
# Components alias: @/components
# Utils alias: @/lib/utils
```

### Required shadcn/ui Components
```bash
npx shadcn@latest add \
  button input label textarea select checkbox \
  card dialog sheet sidebar \
  table badge avatar separator \
  dropdown-menu navigation-menu command \
  tabs popover tooltip \
  toast sonner \
  form
```

### Additional NPM Packages
```bash
npm install lucide-react           # Icons (used by shadcn/ui)
npm install react-dropzone         # Drag & drop file upload
npm install recharts               # Charts for admin dashboard
npm install @tiptap/react @tiptap/starter-kit  # Rich text editor
npm install date-fns               # Date formatting
```

---

## Page Layouts

### AuthLayout
- Centered card on gradient/neutral background
- Logo at top
- No sidebar or navbar

### AppLayout (main layout)
- **Sidebar** (collapsible):
  - Logo
  - Navigation: Dashboard, My Requests, New Request, Notifications
  - User menu at bottom (profile, logout)
  - Role-based menu items (Admin link for super_admin)
- **Top bar**: breadcrumbs, notification bell, user avatar
- **Main content area**

### AdminLayout (extends AppLayout)
- Sidebar with admin-specific nav:
  - Dashboard, Users, Reports, Settings

---

## Key Pages

### 1. Login (`auth/Login.tsx`)
```
┌──────────────────────────────┐
│         [Logo]               │
│                              │
│    ┌──────────────────┐      │
│    │  Sign In          │      │
│    │                  │      │
│    │  Email: [______] │      │
│    │  Pass:  [______] │      │
│    │                  │      │
│    │  [  Sign In    ] │      │
│    │                  │      │
│    │  ── or ──        │      │
│    │                  │      │
│    │  [G] Google      │      │
│    │  [] Apple       │      │
│    │                  │      │
│    │  Forgot password?│      │
│    │  Create account  │      │
│    └──────────────────┘      │
└──────────────────────────────┘
```

### 2. Register (`auth/Register.tsx`)
- Name, Email, Password, Confirm Password
- Google & Apple OAuth buttons
- Privacy policy checkbox

### 2b. Complete Profile (`profile/Complete.tsx`) — shown after first login
```
┌──────────────────────────────┐
│       Complete Your Profile   │
│                              │
│  WhatsApp*: [+34_________]   │
│  Phone:     [____________]   │
│  Birthday:  [DD/MM/YYYY]     │
│  Country:   [__________▼]    │
│                              │
│  [ Save & Continue ]         │
└──────────────────────────────┘
```
* WhatsApp is required — it's used for CRM communication

### 3. My Requests (`requests/Index.tsx`)
```
┌─ Sidebar ─┐┌── Main Content ──────────────────────────┐
│            ││                                          │
│ Dashboard  ││  My Requests                             │
│ Requests ● ││                                          │
│ New Request││  [Search...________]  Status: [Any  ▼]   │
│ Notif (3)  ││                                          │
│            ││  ┌──────────────────────────────────────┐ │
│            ││  │ Subject    │ ID    │ Created│ Status │ │
│            ││  ├───────────────────────────────────────┤ │
│            ││  │ Equiv...   │#66763│ 2 mo   │🟡 Wait │ │
│            ││  │ Equiv...   │#63793│ 4 mo   │🟢 Done │ │
│            ││  │ ...        │      │        │        │ │
│            ││  └──────────────────────────────────────┘ │
│            ││                                          │
│ ── user ── ││  [< 1 2 3 >]                            │
│ [Profile]  ││                                          │
│ [Logout]   ││                                          │
└────────────┘└──────────────────────────────────────────┘
```

### 4. Submit a Request (`requests/New.tsx`)
12 fields + file uploads. Kept simple to not overwhelm the student.
```
┌─ Sidebar ─┐┌── Main Content ──────────────────────────┐
│            ││                                          │
│            ││  Submit a Request                        │
│            ││                                          │
│            ││  ── About You ──                         │
│            ││  Name and Surname: [John Doe________]    │
│            ││  Identity Card/DNI: [______________]     │
│            ││  Passport: [_______________________]     │
│            ││                                          │
│            ││  ── Your Request ──                      │
│            ││  Service Requested: [Equivalencia  ▼]    │
│            ││  Subject: [________________________]     │
│            ││  Description: ┌─────────────────────┐    │
│            ││               │ B I U │ list │       │    │
│            ││               │                     │    │
│            ││               └─────────────────────┘    │
│            ││                                          │
│            ││  ── Education ──                         │
│            ││  Education System: [_______________▼]    │
│            ││  Studies Finished?: [______________▼]    │
│            ││  Type of Studies: [________________▼]    │
│            ││  Studies in Spain: [________________]    │
│            ││  University: [____________________▼]     │
│            ││                                          │
│            ││  ── Optional ──                          │
│            ││  Language Level: [________________▼]     │
│            ││  Language Certificate: [__________▼]     │
│            ││  How did you find us?: [__________▼]     │
│            ││                                          │
│            ││  ── Documents ──                         │
│            ││  Application (заявление):                │
│            ││  ┌──────────────────────────────────┐    │
│            ││  │  Drop file here or [Add file]    │    │
│            ││  └──────────────────────────────────┘    │
│            ││  Originals (оригиналы документов):       │
│            ││  ┌──────────────────────────────────┐    │
│            ││  │  Drop files here or [Add files]  │    │
│            ││  └──────────────────────────────────┘    │
│            ││  - diploma_scan.pdf  ✕                   │
│            ││  Other documents:                        │
│            ││  ┌──────────────────────────────────┐    │
│            ││  │  Drop files here or [Add files]  │    │
│            ││  └──────────────────────────────────┘    │
│            ││                                          │
│            ││  ☐ I accept the privacy policy           │
│            ││                                          │
│            ││  [Save Draft]          [ Submit ]        │
└────────────┘└──────────────────────────────────────────┘
```

### 5. Request Detail + Chat (`requests/Show.tsx`)
```
┌─ Sidebar ─┐┌── Chat ─────────────────┐┌── Details ────────┐
│            ││                         ││ Status: 🟡 Review │
│            ││  [Student] 14 Nov 2025  ││                   │
│            ││  Buenos dias, solicito  ││ Service: Equiv.   │
│            ││  la equivalencia de...  ││ University: CEU   │
│            ││                         ││ System: Colombia  │
│            ││  [Coordinator] 14 Nov   ││                   │
│            ││  Your documentation is  ││ ── Documents ──   │
│            ││  correct. Please pay... ││ Application:      │
│            ││                         ││ 📄 solicitud.pdf  │
│            ││  [Student] 15 Nov       ││ Originals:        │
│            ││  Payment done, receipt  ││ 📄 diploma.pdf    │
│            ││  attached.              ││ 📄 notas.pdf      │
│            ││                         ││   [Download All]  │
│            ││                         ││                   │
│            ││                         ││ ── Payment ──     │
│            ││                         ││ Amount: €60.00    │
│            ││ ┌─────────────────────┐ ││ Status: Confirmed │
│            ││ │ Type a message... 📎│ ││ CRM: ✅ Synced    │
│            ││ │              [Send] │ ││                   │
│            ││ └─────────────────────┘ ││ [Confirm Payment] │
└────────────┘└─────────────────────────┘│ (coordinator only)│
                                         └───────────────────┘
```
Note: "Confirm Payment" button opens a dialog where coordinator enters Sale € amount.
After confirmation, CRM sync status shows: Synced / Syncing / Error + retry.

### 6. Admin Dashboard (`admin/Dashboard.tsx`)
```
┌─ Admin Sidebar ─┐┌── Main Content ─────────────────────┐
│                  ││                                     │
│ Dashboard ●      ││  Dashboard                          │
│ Users            ││                                     │
│ Reports          ││  ┌──────┐ ┌──────┐ ┌──────┐ ┌────┐ │
│                  ││  │  156 │ │  23  │ │  12  │ │ 121│ │
│                  ││  │Total │ │Open  │ │Wait  │ │Done│ │
│                  ││  └──────┘ └──────┘ └──────┘ └────┘ │
│                  ││                                     │
│                  ││  ┌─── Requests Over Time ─────────┐ │
│                  ││  │ 📈 Line Chart                  │ │
│                  ││  └────────────────────────────────┘ │
│                  ││                                     │
│                  ││  ┌─── By Status ──┐┌── Avg Time ──┐ │
│                  ││  │ 🥧 Pie Chart   ││ 📊 Bar Chart │ │
│                  ││  └────────────────┘└──────────────┘ │
│                  ││                                     │
│ ← Back to App   ││  Recent Requests                    │
│                  ││  [Table with latest requests...]    │
└──────────────────┘└─────────────────────────────────────┘
```

### 7. Admin Users (`admin/Users.tsx`)
```
Users Management

[Search...________]  Role: [Any ▼]  [+ Add User]

┌────────────────────────────────────────────────────┐
│ Name      │ Email         │ Roles      │ Actions   │
├────────────────────────────────────────────────────┤
│ Maria G.  │ m@ex.com      │ coordinator│ [Edit][X] │
│ Pedro L.  │ p@ex.com      │ teacher    │ [Edit][X] │
│ Ana K.    │ a@ex.com      │ student    │ [Edit][X] │
└────────────────────────────────────────────────────┘
```

## Reusable Components

| Component            | Location                          | Description                      |
|----------------------|-----------------------------------|----------------------------------|
| `AppLayout`          | `components/layouts/`             | Main layout with sidebar         |
| `AuthLayout`         | `components/layouts/`             | Centered auth layout             |
| `AdminLayout`        | `components/layouts/`             | Admin layout with admin sidebar  |
| `RequestForm`        | `components/requests/`            | Full request form                |
| `RequestTable`       | `components/requests/`            | Filterable request list          |
| `RequestStatusBadge` | `components/requests/`            | Colored status badge             |
| `ChatWindow`         | `components/chat/`                | Full chat component              |
| `MessageBubble`      | `components/chat/`                | Single message display           |
| `MessageInput`       | `components/chat/`                | Text input + send + attach       |
| `FileDropZone`       | `components/documents/`           | Drag & drop upload area          |
| `FileList`           | `components/documents/`           | List of files with download      |
| `StatsCard`          | `components/admin/`               | Number stat with icon            |
| `Chart`              | `components/admin/`               | Recharts wrapper                 |
| `UserTable`          | `components/admin/`               | Admin user management table      |
| `RoleGuard`          | `components/`                     | Role-based rendering             |
| `NotificationBell`   | `components/`                     | Bell icon with dropdown          |
