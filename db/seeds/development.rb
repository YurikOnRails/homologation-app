require "faker"

# =============================================================================
# seeds/development.rb — тестовые данные для локальной разработки
# =============================================================================
# Запуск:   bin/rails db:reset
# Идемпотентно: безопасно запускать повторно (find_or_initialize_by)
#
# ТЕСТОВЫЕ АККАУНТЫ (все с паролем: password123)
# ─────────────────────────────────────────────────────────────────────────────
#  Роль          Email                   Что видит
#  ──────────    ─────────────────────   ──────────────────────────────────────
#  super_admin   boss@example.com        Всё: дашборд, управление пользователями
#  coordinator   maria@example.com       Inbox, заявки, чат, подтверждение оплаты
#  coordinator   carlos@example.com      То же
#  coordinator   sofia@example.com       То же
#  teacher       ivan@example.com        Уроки, календарь, чат со студентами
#  teacher       elena@example.com       То же
#  teacher       omar@example.com        То же
#  student       ana@example.com         Свои заявки, загрузка файлов, чат
#  student       pedro@example.com       То же
#  student       (18 рандомных)          То же
# =============================================================================

# ─── Константы ────────────────────────────────────────────────────────────────

PASSWORD = "password123"

# Статусы с весами: заявки равномерно распределены по всем стадиям
REQUEST_STATUSES_WEIGHTED = (
  %w[submitted]         * 3 +
  %w[in_review]         * 5 +
  %w[awaiting_reply]    * 3 +
  %w[awaiting_payment]  * 4 +
  %w[payment_confirmed] * 2 +
  %w[in_progress]       * 4 +
  %w[resolved]          * 5 +
  %w[closed]            * 2
).freeze

SERVICE_TYPES = %w[equivalencia invoice informe other].freeze
EDU_SYSTEMS   = %w[argentina colombia mexico peru venezuela russia ukraine other].freeze
STUDY_TYPES   = %w[bachillerato fp_medio fp_superior grado master doctorado].freeze
UNIVERSITIES  = %w[ucm uam ceu ue other].freeze
LANG_LEVELS   = %w[a1 a2 b1 b2 c1 c2 none].freeze
LANG_CERTS    = %w[dele siele other none].freeze
REFERRALS     = %w[google instagram facebook friend university other].freeze
COUNTRIES     = %w[AR CO MX PE VE RU UA US ES DE FR IT].freeze

SUBJECTS = [
  "Equivalencia de Grado en Informática",
  "Homologación de Título de Medicina",
  "Equivalencia de Máster en Educación",
  "Reconocimiento de Título de Ingeniería",
  "Equivalencia de Licenciatura en Derecho",
  "Homologación de Título de Arquitectura",
  "Equivalencia de Grado en Psicología",
  "Reconocimiento de Diplomatura en Enfermería",
  "Equivalencia de Título de Economía",
  "Homologación de Ingeniería Industrial",
  "Equivalencia de Grado en Química",
  "Reconocimiento de Título de Biología",
  "Homologación de Título de Farmacia",
  "Equivalencia de Grado en Matemáticas",
  "Reconocimiento de Licenciatura en Letras"
].freeze

COORDINATOR_MESSAGES = [
  "Hemos recibido su solicitud. La estamos revisando.",
  "Necesitamos que nos envíe una copia del título original.",
  "Su documentación está completa. Pasamos a la siguiente etapa.",
  "¿Puede confirmar la fecha de expedición del título?",
  "El proceso de homologación puede tardar entre 3 y 6 meses.",
  "Hemos enviado su expediente al Ministerio de Educación.",
  "Por favor, adjunte también el certificado académico.",
  "Todo está correcto. Procedemos con el pago."
].freeze

STUDENT_MESSAGES = [
  "Muchas gracias por la información.",
  "He adjuntado los documentos que solicitó.",
  "¿Cuánto tiempo tardará aproximadamente?",
  "¿Necesitan algún documento adicional?",
  "Perfecto, procedo con el pago ahora mismo.",
  "He enviado los documentos por correo también.",
  "¿Es posible acelerar el proceso?",
  "Gracias, quedo a la espera de noticias."
].freeze

# ─── Хелперы ──────────────────────────────────────────────────────────────────

def find_role(name)
  Role.find_by!(name: name)
end

def seed_user(email:, name:, role_name:, locale: "es", country: "ES")
  role = find_role(role_name)
  user = User.find_or_initialize_by(email_address: email)
  user.assign_attributes(
    name: name,
    locale: locale,
    country: country,
    whatsapp: Faker::PhoneNumber.cell_phone_in_e164,
    birthday: Faker::Date.birthday(min_age: 20, max_age: 45),
    notification_email: true,
    notification_telegram: false,
    is_minor: false
  )
  user.password = PASSWORD if user.new_record?
  user.save!
  user.roles << role unless user.roles.include?(role)
  user
end

# ─── Начало ───────────────────────────────────────────────────────────────────

puts "\n#{"=" * 60}"
puts "  🌱  Seeding development database"
puts "=" * 60

# ─── 1. Именованные тестовые пользователи ─────────────────────────────────────
puts "\n👤 Named test users (password: #{PASSWORD})\n"

boss   = seed_user(email: "boss@example.com",   name: "Boss Admin",    role_name: "super_admin", locale: "es", country: "ES")
maria  = seed_user(email: "maria@example.com",  name: "Maria Garcia",  role_name: "coordinator", locale: "es", country: "ES")
carlos = seed_user(email: "carlos@example.com", name: "Carlos Ruiz",   role_name: "coordinator", locale: "es", country: "ES")
sofia  = seed_user(email: "sofia@example.com",  name: "Sofía Méndez",  role_name: "coordinator", locale: "es", country: "ES")
ivan   = seed_user(email: "ivan@example.com",   name: "Ivan Petrov",   role_name: "teacher",     locale: "ru", country: "RU")
elena  = seed_user(email: "elena@example.com",  name: "Elena Sokolova", role_name: "teacher",     locale: "ru", country: "RU")
omar   = seed_user(email: "omar@example.com",   name: "Omar Hassan",   role_name: "teacher",     locale: "es", country: "ES")
ana    = seed_user(email: "ana@example.com",    name: "Ana Kowalski",  role_name: "student",     locale: "es", country: "RU")
pedro  = seed_user(email: "pedro@example.com",  name: "Pedro Lopez",   role_name: "student",     locale: "es", country: "CO")

puts "  boss@example.com    → super_admin"
puts "  maria@example.com   → coordinator"
puts "  carlos@example.com  → coordinator"
puts "  sofia@example.com   → coordinator"
puts "  ivan@example.com    → teacher"
puts "  elena@example.com   → teacher"
puts "  omar@example.com    → teacher"
puts "  ana@example.com     → student"
puts "  pedro@example.com   → student"

coordinators = [ maria, carlos, sofia ]
teachers     = [ ivan, elena, omar ]

# ─── 2. Дополнительные студенты (рандомные, для объёма) ───────────────────────
puts "\n👤 Extra students (random, for volume)..."

extra_students = 18.times.map do
  seed_user(
    email:     Faker::Internet.unique.email,
    name:      Faker::Name.name,
    role_name: "student",
    locale:    %w[es ru en].sample,
    country:   COUNTRIES.sample
  )
end
students = [ ana, pedro ] + extra_students
puts "  ✅ #{students.size} students total"

# ─── 3. Привязки учитель → студент + чат пары ─────────────────────────────────
puts "\n📎 Teacher-student assignments..."

assignments_created = 0
students.each_with_index do |student, i|
  teacher = teachers[i % teachers.size]
  next if TeacherStudent.exists?(teacher_id: teacher.id, student_id: student.id)

  ts = TeacherStudent.create!(
    teacher_id: teacher.id,
    student_id: student.id,
    assigned_by: maria.id
  )

  next if Conversation.exists?(teacher_student_id: ts.id)

  conv = Conversation.create!(teacher_student_id: ts.id)
  conv.add_participant!(teacher)
  conv.add_participant!(student)

  rand(2..5).times do
    sender = [ teacher, student ].sample
    Message.create!(
      conversation: conv,
      user: sender,
      body: sender == teacher ? COORDINATOR_MESSAGES.sample : STUDENT_MESSAGES.sample,
      created_at: Faker::Time.between(from: 3.months.ago, to: Time.current)
    )
  end

  assignments_created += 1
end
puts "  ✅ #{assignments_created} assignments + chat conversations"

# ─── 4. Уроки (прошедшие + предстоящие) ───────────────────────────────────────
puts "\n📅 Lessons..."

lessons_created = 0
TeacherStudent.all.each do |ts|
  rand(3..6).times do
    status = %w[completed completed completed cancelled].sample
    Lesson.create!(
      teacher_id:       ts.teacher_id,
      student_id:       ts.student_id,
      scheduled_at:     Faker::Time.between(from: 6.months.ago, to: 1.day.ago),
      duration_minutes: [ 60, 90 ].sample,
      status:           status,
      notes:            status == "cancelled" ? "Cancelado por el estudiante." : Faker::Lorem.sentence(word_count: 8)
    ) rescue nil
    lessons_created += 1
  end

  rand(1..2).times do
    Lesson.new(
      teacher_id:       ts.teacher_id,
      student_id:       ts.student_id,
      scheduled_at:     Faker::Time.between(from: 1.day.from_now, to: 30.days.from_now),
      duration_minutes: 60,
      status:           "scheduled"
    ).save(validate: false)
    lessons_created += 1
  end
end
puts "  ✅ #{lessons_created} lessons (past + upcoming)"

# ─── 5. Заявки на гомологацию (распределены по 12 месяцам) ────────────────────
puts "\n📄 Homologation requests..."

requests_created = 0
coordinator_cycle = coordinators.cycle

students.each do |student|
  rand(1..3).times do
    status      = REQUEST_STATUSES_WEIGHTED.sample
    coordinator = coordinator_cycle.next
    created     = Faker::Time.between(from: 11.months.ago, to: 1.week.ago)

    req = HomologationRequest.new(
      user:                student,
      coordinator:         coordinator,
      subject:             SUBJECTS.sample,
      service_type:        SERVICE_TYPES.sample,
      description:         Faker::Lorem.paragraph(sentence_count: 3),
      education_system:    EDU_SYSTEMS.sample,
      studies_finished:    %w[yes yes in_progress].sample,
      study_type_spain:    STUDY_TYPES.sample,
      studies_spain:       "yes",
      university:          UNIVERSITIES.sample,
      referral_source:     REFERRALS.sample,
      language_knowledge:  LANG_LEVELS.sample,
      language_certificate: LANG_CERTS.sample,
      identity_card:       Faker::IdNumber.spanish_citizen_number,
      passport:            "#{("A".."Z").to_a.sample}#{Faker::Number.number(digits: 7)}",
      privacy_accepted:    true,
      status:              status,
      status_changed_at:   created + rand(1..30).days,
      status_changed_by:   coordinator.id,
      created_at:          created,
      updated_at:          created + rand(1..45).days
    )

    if %w[payment_confirmed in_progress resolved closed].include?(status)
      req.payment_amount       = [ 250, 350, 450, 550, 650 ].sample
      req.payment_confirmed_at = created + rand(10..30).days
      req.payment_confirmed_by = coordinator.id
    end

    if %w[in_progress resolved].include?(status) && rand < 0.7
      req.amo_crm_lead_id  = Faker::Number.number(digits: 8).to_s
      req.amo_crm_synced_at = req.payment_confirmed_at&.+ rand(1..3).hours
    end

    req.amo_crm_sync_error = "Connection timeout: AmoCRM API unreachable" if rand < 0.08

    req.save(validate: false)
    requests_created += 1

    next if req.status == "draft" || req.conversation.present?

    conv = Conversation.create!(homologation_request: req)
    conv.add_participant!(student)
    conv.add_participant!(coordinator)

    msg_count = case status
    when "submitted"                       then rand(0..2)
    when "in_review"                       then rand(1..3)
    when "awaiting_reply"                  then rand(2..5)
    when "awaiting_payment"                then rand(3..6)
    when "payment_confirmed", "in_progress" then rand(4..8)
    when "resolved", "closed"              then rand(5..10)
    else 0
    end

    msg_time = created + 1.hour
    msg_count.times do |i|
      sender   = i.even? ? coordinator : student
      msg_time += rand(1..72).hours
      break if msg_time > Time.current
      Message.create!(
        conversation: conv,
        user:         sender,
        body:         sender == coordinator ? COORDINATOR_MESSAGES.sample : STUDENT_MESSAGES.sample,
        created_at:   msg_time
      )
    end
  end
end
puts "  ✅ #{requests_created} requests"

# ─── 6. Уведомления ───────────────────────────────────────────────────────────
puts "\n🔔 Notifications..."

notif_count = 0
HomologationRequest.last(15).each do |req|
  Notification.find_or_create_by!(user: req.user, notifiable: req, title: "Estado actualizado: #{req.status}") do |n|
    n.read_at    = rand < 0.4 ? Faker::Time.between(from: req.updated_at, to: Time.current) : nil
    n.created_at = req.updated_at
  end

  Notification.find_or_create_by!(user: req.coordinator, notifiable: req, title: "Nueva solicitud de #{req.user.name}") do |n|
    n.read_at    = rand < 0.7 ? Faker::Time.between(from: req.created_at, to: Time.current) : nil
    n.created_at = req.created_at
  end

  notif_count += 2
end
puts "  ✅ #{notif_count} notifications"

# ─── Итоговая сводка ──────────────────────────────────────────────────────────

sync_errors = HomologationRequest.where.not(amo_crm_sync_error: nil).count

puts <<~SUMMARY

  #{"=" * 60}
    ✅  Development seed complete!
  #{"=" * 60}

    ТЕСТОВЫЕ АККАУНТЫ — все с паролем: #{PASSWORD}
    ──────────────────────────────────────────────
    super_admin   boss@example.com
    coordinator   maria@example.com
    coordinator   carlos@example.com
    coordinator   sofia@example.com
    teacher       ivan@example.com
    teacher       elena@example.com
    teacher       omar@example.com
    student       ana@example.com
    student       pedro@example.com
    + #{User.count - 9} случайных студентов (Faker email)

    ДАННЫЕ В БД
    ──────────────────────────────────────────────
    Пользователи:   #{User.count}
    Заявки:         #{HomologationRequest.count} (#{sync_errors} с ошибкой CRM-синхронизации)
    Уроки:          #{Lesson.count}
    Сообщения:      #{Message.count}
    Уведомления:    #{Notification.count}

  #{"=" * 60}
SUMMARY
