# Prompt: Migrate Test Suite from Fixtures to FactoryBot + Faker

## Goal

Migrate the existing test suite from **Minitest + Fixtures** to **Minitest + FactoryBot + Faker**.
Keep Minitest as the test framework. Do NOT switch to RSpec. Do NOT change any production code.

---

## Current State

- **Framework:** Minitest (Rails 8.1.2, Ruby 3.4.9)
- **414 tests**, 45 test files
- **12 fixture files** with 28 fixture records total
- **Test categories:** controllers (20 files), models (9 files), policies (9 files), jobs (6 files), services (1 file)
- **Parallelization:** enabled (`parallelize(workers: :number_of_processors)`)
- **Inertia.js integration:** uses `inertia.component` and `inertia.props` for assertions
- **Custom helpers:** `SessionTestHelper` (sign_in/sign_out via cookie-based sessions)
- **Faker** already in Gemfile (in `:development, :test` group) but unused in tests
- **WebMock** used in services/jobs tests for HTTP stubbing
- **Active Storage** tested with `fixture_file_upload` and `file_fixture`

## Target State

- **Minitest** stays as the test framework
- **FactoryBot** replaces all YAML fixtures
- **Faker** generates realistic data in factories
- All 414 tests pass, same test count, same test names
- Parallel tests still work

---

## Inventory of Existing Fixtures

### test/fixtures/users.yml (5 records)

```yaml
super_admin_boss:    # email: boss@example.com, country: ES, has_homologation: true, has_education: true
coordinator_maria:   # email: maria@example.com, country: ES, has_homologation: true, has_education: false
teacher_ivan:        # email: ivan@example.com, country: RU, locale: ru, has_homologation: false, has_education: true
student_ana:         # email: ana@example.com, country: RU, has_homologation: true, has_education: false
student_pedro:       # email: pedro@example.com, country: CO (Spanish-speaking), has_homologation: true, has_education: false
```

All users share `password_digest: BCrypt::Password.create("password123")`.

### test/fixtures/roles.yml (4 records)
```yaml
super_admin, coordinator, teacher, student
```

### test/fixtures/user_roles.yml (5 records)
```yaml
super_admin_boss → super_admin
coordinator_maria → coordinator
teacher_ivan → teacher
student_ana → student
student_pedro → student
```

### test/fixtures/homologation_requests.yml (2 records)
```yaml
ana_equivalencia:  # user: student_ana, service_type: equivalencia, status: submitted, privacy_accepted: true
ana_draft:         # user: student_ana, service_type: equivalencia, status: draft, privacy_accepted: false
```

### test/fixtures/conversations.yml (2 records)
```yaml
ana_equivalencia_conversation:  # homologation_request: ana_equivalencia
ivan_ana_conversation:          # teacher_student: ivan_ana
```

### test/fixtures/conversation_participants.yml (4 records)
```yaml
ana_in_equivalencia_conversation, maria_in_equivalencia_conversation
ivan_in_ivan_ana_conversation, ana_in_ivan_ana_conversation
```

### test/fixtures/messages.yml (2 records)
```yaml
ana_message_1:   # conversation: ana_equivalencia_conversation, user: student_ana
maria_message_1: # conversation: ana_equivalencia_conversation, user: coordinator_maria
```

### test/fixtures/notifications.yml (1 record)
```yaml
ana_unread_notification:  # user: student_ana, notifiable: ana_equivalencia, read_at: nil
```

### test/fixtures/lessons.yml (1 record)
```yaml
ivan_ana_lesson:  # teacher: teacher_ivan, student: student_ana, status: scheduled, scheduled_at: future
```

### test/fixtures/teacher_profiles.yml (1 record)
```yaml
ivan_profile:  # user: teacher_ivan, level: senior, hourly_rate: 25.00, permanent_meeting_link: zoom url
```

### test/fixtures/teacher_students.yml (1 record)
```yaml
ivan_ana:  # teacher: teacher_ivan, student: student_ana, assigned_by: coordinator_maria
```

### test/fixtures/amo_crm_tokens.yml (0 records)
```yaml
# No fixtures — token managed at runtime
```

---

## Fixture → Factory Mapping Reference

| Fixture Call | Factory Replacement |
|---|---|
| `users(:super_admin_boss)` | `create(:user, :super_admin)` |
| `users(:coordinator_maria)` | `create(:user, :coordinator)` |
| `users(:teacher_ivan)` | `create(:user, :teacher)` |
| `users(:student_ana)` | `create(:user, :student)` (country: "RU" by default) |
| `users(:student_pedro)` | `create(:user, :student, :spanish_speaking)` |
| `roles(:super_admin)` | `Role.find_or_create_by!(name: "super_admin")` |
| `homologation_requests(:ana_equivalencia)` | `create(:homologation_request, :submitted, user: student)` |
| `homologation_requests(:ana_draft)` | `create(:homologation_request, :draft, user: student)` |
| `conversations(:ana_equivalencia_conversation)` | `student.homologation_requests.first.conversation` (auto-created on submitted) |
| `conversations(:ivan_ana_conversation)` | `create(:conversation, :for_teacher_student, teacher_student_link: ts)` |
| `messages(:ana_message_1)` | `create(:message, conversation: conv, user: student)` |
| `notifications(:ana_unread_notification)` | `create(:notification, user: student)` |
| `lessons(:ivan_ana_lesson)` | `create(:lesson, teacher: teacher, student: student)` |
| `teacher_profiles(:ivan_profile)` | `create(:teacher_profile, user: teacher)` |
| `teacher_students(:ivan_ana)` | `create(:teacher_student, teacher: teacher, student: student)` |

---

## Step-by-step Migration Plan

### Step 1: Add gem and configure

Add to Gemfile (test group):
```ruby
group :test do
  gem "factory_bot_rails"
  # ... existing gems
end
```

Run `bundle install`.

Update `test/test_helper.rb`:
```ruby
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"
require "inertia_rails/testing"

InertiaRails::Testing.install!

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    include FactoryBot::Syntax::Methods  # build, create, build_stubbed

    # Ensure roles exist (idempotent) — roles are global constants
    setup do
      %w[super_admin coordinator teacher student].each do |name|
        Role.find_or_create_by!(name: name)
      end
    end
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) do
  include InertiaRails::Testing::Helpers
end
```

Key changes:
- Remove `fixtures :all`
- Add `include FactoryBot::Syntax::Methods`
- Add role seeding in `setup` block (runs once per test, idempotent via `find_or_create_by!`)

### Step 2: Create factories

Create `test/factories/` directory. One file per model. Use Faker for all human-readable fields. Keep internal keys (status, role names, country codes) as explicit strings.

#### test/factories/users.rb

```ruby
FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email_address { Faker::Internet.unique.email }
    password_digest { BCrypt::Password.create("password123") }
    locale { "es" }
    is_minor { false }
    notification_email { true }
    notification_telegram { false }
    whatsapp { Faker::PhoneNumber.cell_phone_in_e164 }
    birthday { Faker::Date.birthday(min_age: 18, max_age: 40) }
    country { "RU" }
    has_homologation { true }
    has_education { false }

    # Role traits — add the role association after create
    trait :super_admin do
      has_homologation { true }
      has_education { true }
      after(:create) { |u| u.roles << Role.find_by!(name: "super_admin") }
    end

    trait :coordinator do
      after(:create) { |u| u.roles << Role.find_by!(name: "coordinator") }
    end

    trait :teacher do
      has_homologation { false }
      has_education { true }
      after(:create) { |u| u.roles << Role.find_by!(name: "teacher") }
    end

    trait :student do
      after(:create) { |u| u.roles << Role.find_by!(name: "student") }
    end

    trait :spanish_speaking do
      country { %w[AR CO MX PE VE CU EC BO CL PY UY].sample }
    end
  end
end
```

**Why `Role.find_by!` not `find_or_create_by!`:** Roles are seeded in `test_helper.rb setup` block before any factory runs. Using `find_by!` catches bugs if roles are missing.

#### test/factories/roles.rb

```ruby
FactoryBot.define do
  factory :role do
    name { "student" }

    trait(:super_admin)  { name { "super_admin" } }
    trait(:coordinator)  { name { "coordinator" } }
    trait(:teacher)      { name { "teacher" } }
    trait(:student)      { name { "student" } }
  end
end
```

This factory exists only for edge-case tests. Prefer `Role.find_by!(name: ...)` in user traits.

#### test/factories/homologation_requests.rb

```ruby
FactoryBot.define do
  factory :homologation_request do
    association :user, :student
    subject { Faker::Lorem.sentence(word_count: 3) }
    service_type { "equivalencia" }
    status { "submitted" }
    privacy_accepted { true }

    trait :draft do
      status { "draft" }
      privacy_accepted { false }
    end

    trait :submitted do
      status { "submitted" }
      privacy_accepted { true }
    end

    trait :awaiting_payment do
      status { "awaiting_payment" }
      privacy_accepted { true }
    end

    trait :payment_confirmed do
      status { "payment_confirmed" }
      privacy_accepted { true }
      payment_amount { Faker::Commerce.price(range: 50..500.0) }
      payment_confirmed_at { Time.current }
    end

    trait :in_pipeline do
      payment_confirmed
      pipeline_stage { "pago_recibido" }
      document_checklist { HomologationRequest::DEFAULT_DOCUMENT_CHECKLIST }
      year { Time.current.year }
    end

    trait :with_conversation do
      after(:create) do |request|
        conv = Conversation.create!(homologation_request: request)
        conv.conversation_participants.create!(user: request.user)
      end
    end

    trait :with_files do
      after(:create) do |request|
        request.originals.attach(
          io: StringIO.new("fake pdf content"),
          filename: "document.pdf",
          content_type: "application/pdf"
        )
      end
    end
  end
end
```

**Important:** The default factory creates a `submitted` request (most common in tests). Use `:draft` trait explicitly for draft tests. The `:with_conversation` trait is separate because `submitted` records auto-create conversations via `after_save` callback only on real transition — factory insert bypasses callbacks.

#### test/factories/conversations.rb

```ruby
FactoryBot.define do
  factory :conversation do
    # Polymorphic — must have exactly one of these associations
    trait :for_request do
      association :homologation_request
    end

    trait :for_teacher_student do
      association :teacher_student_link, factory: :teacher_student
    end
  end
end
```

#### test/factories/conversation_participants.rb

```ruby
FactoryBot.define do
  factory :conversation_participant do
    association :conversation
    association :user
  end
end
```

#### test/factories/messages.rb

```ruby
FactoryBot.define do
  factory :message do
    association :conversation
    association :user
    body { Faker::Lorem.paragraph(sentence_count: 2) }
  end
end
```

#### test/factories/notifications.rb

```ruby
FactoryBot.define do
  factory :notification do
    association :user, :student
    title { Faker::Lorem.sentence }
    read_at { nil }
    notifiable { association :homologation_request }

    trait :read do
      read_at { 1.hour.ago }
    end
  end
end
```

#### test/factories/lessons.rb

```ruby
FactoryBot.define do
  factory :lesson do
    association :teacher, factory: [:user, :teacher]
    association :student, factory: [:user, :student]
    scheduled_at { 1.day.from_now.change(hour: 10) }
    duration_minutes { 60 }
    status { "scheduled" }

    trait :cancelled do
      status { "cancelled" }
    end

    trait :completed do
      status { "completed" }
    end
  end
end
```

#### test/factories/teacher_profiles.rb

```ruby
FactoryBot.define do
  factory :teacher_profile do
    association :user, :teacher
    level { "senior" }
    hourly_rate { 25.00 }
    permanent_meeting_link { Faker::Internet.url(host: "zoom.us") }
    bio { Faker::Lorem.paragraph }
  end
end
```

#### test/factories/teacher_students.rb

```ruby
FactoryBot.define do
  factory :teacher_student do
    association :teacher, factory: [:user, :teacher]
    association :student, factory: [:user, :student]
    association :assigned_by, factory: [:user, :coordinator]
  end
end
```

### Step 3: Migrate tests — file by file

**Migration pattern for each fixture call:**

| Pattern | Before (fixtures) | After (FactoryBot) |
|---|---|---|
| Named user | `users(:student_ana)` | `create(:user, :student)` — assigned to a local variable or `setup` |
| Named request | `homologation_requests(:ana_equivalencia)` | `create(:homologation_request, :submitted, :with_conversation, user: student)` |
| Named draft | `homologation_requests(:ana_draft)` | `create(:homologation_request, :draft, user: student)` |
| Named conversation | `conversations(:ana_equivalencia_conversation)` | `request.conversation` (from submitted request with_conversation) |
| Named message | `messages(:ana_message_1)` | `create(:message, conversation: conv, user: student)` |
| Named notification | `notifications(:ana_unread_notification)` | `create(:notification, user: student)` |
| Named lesson | `lessons(:ivan_ana_lesson)` | `create(:lesson, teacher: teacher, student: student)` |
| Named teacher_student | `teacher_students(:ivan_ana)` | `create(:teacher_student, teacher: teacher, student: student)` |
| Named teacher_profile | `teacher_profiles(:ivan_profile)` | `create(:teacher_profile, user: teacher)` |
| Named role | `roles(:student)` | `Role.find_by!(name: "student")` |

**Use `setup` blocks to create shared data within each test class.** Records created in `setup` are rolled back after each test by Minitest's transactional fixtures replacement.

**Example migration — before (fixtures):**
```ruby
class HomologationRequestsControllerTest < ActionDispatch::IntegrationTest
  test "student sees own requests" do
    sign_in users(:student_ana)
    get homologation_requests_path
    assert_response :ok
    assert_equal "requests/Index", inertia.component
  end

  test "student cannot see other student request" do
    sign_in users(:student_pedro)
    get homologation_request_path(homologation_requests(:ana_equivalencia))
    assert_response :forbidden
  end
end
```

**After (FactoryBot):**
```ruby
class HomologationRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = create(:user, :student)
    @other_student = create(:user, :student, :spanish_speaking)
    @request = create(:homologation_request, :submitted, :with_conversation, user: @student)
  end

  test "student sees own requests" do
    sign_in @student
    get homologation_requests_path
    assert_response :ok
    assert_equal "requests/Index", inertia.component
  end

  test "student cannot see other student request" do
    sign_in @other_student
    get homologation_request_path(@request)
    assert_response :forbidden
  end
end
```

**Migration order (by dependency — migrate simpler tests first):**

1. **`test/factories/`** — create all 10 factory files first
2. **`test/models/`** (9 files) — model tests have fewest dependencies, validate factories work
3. **`test/policies/`** (9 files) — policy tests are self-contained, use user + resource
4. **`test/jobs/`** (6 files) — job tests may need request/user factories, some use WebMock
5. **`test/services/`** (1 file) — AmoCRM client test uses WebMock, minimal fixture usage
6. **`test/controllers/`** (20 files) — largest category, migrate last (most complex setup)

### Step 4: Migrate model tests (9 files)

For each model test file, replace fixture calls with factory calls. Use `setup` for shared records.

**Key patterns in model tests:**

- `homologation_request_test.rb`: Uses `homologation_requests(:ana_draft)`, `homologation_requests(:ana_equivalencia)`, `users(:student_ana)`, `users(:coordinator_maria)`. Many tests modify status with `update_columns`. Create a student, a draft request, and a submitted request in `setup`.

- `pipeline_test.rb`: Heavy use of `homologation_requests(:ana_equivalencia)` with `update_columns` to set pipeline state. Uses `users(:student_ana)` and `users(:student_pedro)` (Spanish-speaking for country routing). Create the `:in_pipeline` trait for these.

- `user_test.rb`: Tests user creation, OAuth, role methods. Needs multiple user types. Create fresh users per test or in `setup`.

- `conversation_test.rb`: Tests `add_participant!` and validation. Needs a conversation with a homologation_request or teacher_student.

- `lesson_test.rb`: Tests `effective_meeting_link` and validations. Needs teacher, student, teacher_profile, teacher_student, lesson.

### Step 5: Migrate policy tests (9 files)

Policy tests instantiate `PolicyClass.new(user, resource)` directly. Replace fixture users with factory users.

**Pattern:**
```ruby
# Before
test "student can view own request" do
  policy = HomologationRequestPolicy.new(users(:student_ana), homologation_requests(:ana_equivalencia))
  assert policy.show?
end

# After
setup do
  @student = create(:user, :student)
  @request = create(:homologation_request, :submitted, user: @student)
end

test "student can view own request" do
  policy = HomologationRequestPolicy.new(@student, @request)
  assert policy.show?
end
```

### Step 6: Migrate job tests (6 files)

- `notification_job_test.rb`: Creates notifications, checks Telegram/email. Uses `users(:student_ana)` and `homologation_requests(:ana_equivalencia)`.
- `amo_crm_sync_job_test.rb`: Uses WebMock stubs. Uses `homologation_requests(:ana_equivalencia)` with payment fields.
- `amo_crm_status_sync_job_test.rb`: Similar to sync job.
- `lesson_reminder_job_test.rb`: Uses `lessons(:ivan_ana_lesson)`.
- `chat_email_digest_job_test.rb`: Uses conversations/messages.
- `database_backup_job_test.rb`: May not use fixtures at all.

### Step 7: Migrate service tests (1 file)

`amo_crm_client_test.rb`: Uses WebMock, minimal fixture usage. Replace any fixture calls.

### Step 8: Migrate controller tests (20 files)

Largest and most complex category. Each controller test file typically needs:
- Multiple user types (admin, coordinator, teacher, student)
- Domain records (requests, conversations, lessons, etc.)
- File attachments (for upload/download tests)

**For `homologation_requests_controller_test.rb` (52 tests):**

```ruby
class HomologationRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, :super_admin)
    @coordinator = create(:user, :coordinator)
    @teacher = create(:user, :teacher)
    @student = create(:user, :student)
    @other_student = create(:user, :student, :spanish_speaking)
    @submitted_request = create(:homologation_request, :submitted, :with_conversation, user: @student)
    @draft_request = create(:homologation_request, :draft, user: @student)
  end

  # Replace all users(:student_ana) → @student
  # Replace all users(:super_admin_boss) → @admin
  # Replace all homologation_requests(:ana_equivalencia) → @submitted_request
  # Replace all homologation_requests(:ana_draft) → @draft_request
  # Keep private helper methods (awaiting_payment_request, request_with_file) but base them on @submitted_request
end
```

**For controller tests that test authorization across roles**, create all needed users in `setup`:
```ruby
setup do
  @admin = create(:user, :super_admin)
  @coordinator = create(:user, :coordinator)
  @teacher = create(:user, :teacher)
  @student = create(:user, :student)
end
```

**For conversation/message controller tests**, create the full conversation chain:
```ruby
setup do
  @student = create(:user, :student)
  @coordinator = create(:user, :coordinator)
  @request = create(:homologation_request, :submitted, :with_conversation, user: @student)
  @conversation = @request.conversation
  @conversation.conversation_participants.create!(user: @coordinator)
end
```

**For lesson controller tests**, create teacher-student assignment:
```ruby
setup do
  @teacher = create(:user, :teacher)
  @student = create(:user, :student)
  @teacher_profile = create(:teacher_profile, user: @teacher)
  @assignment = create(:teacher_student, teacher: @teacher, student: @student)
  @lesson = create(:lesson, teacher: @teacher, student: @student)
end
```

### Step 9: Remove fixtures

After ALL tests pass with factories:
1. Delete all `test/fixtures/*.yml` (12 files)
2. Delete `test/fixtures/files/test_document.pdf` if it exists (replace with `StringIO` in factories or `fixture_file_upload` from a generated temp file)
3. Verify `fixtures :all` is already removed from test_helper.rb (done in Step 1)

### Step 10: Verify

```bash
bin/rails test                # All 414 tests pass
bin/rails test --parallel     # Parallelization still works
```

---

## Critical Rules During Migration

1. **Never change production code** — this is a test-only migration
2. **Green after every file** — migrate one test file, run its tests (`bin/rails test test/models/user_test.rb`), confirm green, then move to the next
3. **Keep test count identical** — 414 tests before = 414 tests after. No skipping, no adding
4. **Preserve test names** — test names are documentation, do not rename them
5. **No shared mutable state** — records in `setup` are per-test (Minitest wraps each test in a transaction and rolls back). If a test needs to modify a record, it's safe because it's isolated
6. **`sign_in` helper stays unchanged** — `SessionTestHelper` works with any User record, not just fixtures
7. **`inertia.props` / `inertia.component` assertions stay unchanged** — Inertia testing helpers are unrelated to data layer
8. **Parallel tests must still work** — FactoryBot + parallel is fine, but avoid `sequence` collisions on unique DB columns. Use `Faker::Internet.unique.email` for emails
9. **`update_columns` in pipeline tests is intentional** — it bypasses validations for test setup. Keep it
10. **Conversations on submitted requests** — when factory creates a submitted request, the `after_save` callback creates a conversation automatically. The `:with_conversation` trait is for cases where you need the conversation AND participants set up without going through the full transition. Check each test to decide which approach is needed
11. **TeacherStudent has no updated_at** — `self.record_timestamps = false` in the model. The factory handles this correctly since `created_at` is set by `before_create` callback
12. **File attachments** — use `StringIO.new("fake content")` in factories. For controller tests that test `fixture_file_upload`, keep using `fixture_file_upload` if the test file still exists, or create the temp file inline
13. **Roles must exist before user factories run** — the `setup` block in `test_helper.rb` seeds roles. This runs before each test. `Role.find_by!` in user trait callbacks will find them

---

## Model Validations to Know (affects factory defaults)

| Model | Key Validations |
|---|---|
| User | email (unique, present), name (present, max 100), password (min 8, present if no provider), locale (inclusion), country (inclusion), at_least_one_cabinet |
| HomologationRequest | subject (present), service_type (present, inclusion in config list), privacy_accepted (if submitted), payment_amount (if payment_confirmed) |
| Conversation | must have either homologation_request_id or teacher_student_id |
| Message | body (present) |
| Notification | title (present) |
| Lesson | status (inclusion), scheduled_at (present, future on create), duration_minutes (> 0), student_must_be_assigned_to_teacher |
| TeacherProfile | level (inclusion in junior/mid/senior/native), hourly_rate (> 0) |
| TeacherStudent | teacher_id + student_id (unique pair) |
| Role | name (unique, inclusion in 4 values) |

**The Lesson factory requires a TeacherStudent assignment to exist** between the teacher and student (custom validation `student_must_be_assigned_to_teacher`). Update the lesson factory to auto-create this:

```ruby
factory :lesson do
  association :teacher, factory: [:user, :teacher]
  association :student, factory: [:user, :student]
  scheduled_at { 1.day.from_now.change(hour: 10) }
  duration_minutes { 60 }
  status { "scheduled" }

  after(:build) do |lesson|
    unless TeacherStudent.exists?(teacher: lesson.teacher, student: lesson.student)
      coordinator = User.joins(:roles).where(roles: { name: "coordinator" }).first || create(:user, :coordinator)
      TeacherStudent.create!(teacher: lesson.teacher, student: lesson.student, assigned_by: coordinator)
    end
  end
end
```

---

## Files to Create

```
test/factories/
  users.rb
  roles.rb
  homologation_requests.rb
  conversations.rb
  conversation_participants.rb
  messages.rb
  notifications.rb
  lessons.rb
  teacher_profiles.rb
  teacher_students.rb
```

## Files to Modify

```
Gemfile                        (add factory_bot_rails to :test group)
test/test_helper.rb            (remove fixtures :all, add FactoryBot include, add role seeding)
test/models/*.rb               (all 9 files)
test/policies/*.rb             (all 9 files)
test/jobs/*.rb                 (all 6 files)
test/services/*.rb             (1 file)
test/controllers/*.rb          (all 20 files)
```

## Files to Delete (after full migration)

```
test/fixtures/*.yml            (all 12 files)
test/fixtures/files/           (test file directory — if exists)
```
