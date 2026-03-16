require "faker"

# ──────────────────────────────────────────────────
# Helpers
# ──────────────────────────────────────────────────
def find_role(name) = Role.find_by!(name: name)

def create_user(email:, name:, role_name:, locale: "es", country: "ES")
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
  user.password = "password123" if user.new_record?
  user.save!
  user.roles << role unless user.roles.include?(role)
  user
end

# Weighted random status: most requests are in active/mid states
REQUEST_STATUSES_WEIGHTED = (
  %w[submitted] * 3 +
  %w[in_review] * 5 +
  %w[awaiting_reply] * 3 +
  %w[awaiting_payment] * 4 +
  %w[payment_confirmed] * 2 +
  %w[in_progress] * 4 +
  %w[resolved] * 5 +
  %w[closed] * 2
).freeze

SERVICE_TYPES  = %w[equivalencia invoice informe other].freeze
EDU_SYSTEMS    = %w[argentina colombia mexico peru venezuela russia ukraine other].freeze
STUDY_TYPES    = %w[bachillerato fp_medio fp_superior grado master doctorado].freeze
UNIVERSITIES   = %w[ucm uam ceu ue other].freeze
LANG_LEVELS    = %w[a1 a2 b1 b2 c1 c2 none].freeze
LANG_CERTS     = %w[dele siele other none].freeze
REFERRALS      = %w[google instagram facebook friend university other].freeze
COUNTRIES      = %w[AR CO MX PE VE RU UA US ES DE FR IT].freeze

COORDINATOR_MESSAGES = [
  "Hemos recibido su solicitud. La estamos revisando.",
  "Necesitamos que nos envíe una copia del título original.",
  "Su documentación está completa. Pasamos a la siguiente etapa.",
  "¿Puede confirmar la fecha de expedición del título?",
  "El proceso de homologación puede tardar entre 3 y 6 meses.",
  "Hemos enviado su expediente al Ministerio de Educación.",
  "Por favor, adjunte también el certificado académico.",
  "Todo está correcto. Procedemos con el pago.",
].freeze

STUDENT_MESSAGES = [
  "Muchas gracias por la información.",
  "He adjuntado los documentos que solicitó.",
  "¿Cuánto tiempo tardará aproximadamente?",
  "¿Necesitan algún documento adicional?",
  "Perfecto, procedo con el pago ahora mismo.",
  "He enviado los documentos por correo también.",
  "¿Es posible acelerar el proceso?",
  "Gracias, quedo a la espera de noticias.",
].freeze

puts "\n🌱 Seeding development data...\n\n"

# ──────────────────────────────────────────────────
# 1. Fixed named users (for easy login)
# ──────────────────────────────────────────────────
puts "👤 Named users..."

boss      = create_user(email: "boss@example.com",  name: "Boss Admin",    role_name: "super_admin", locale: "es", country: "ES")
maria     = create_user(email: "maria@example.com", name: "Maria Garcia",  role_name: "coordinator", locale: "es", country: "ES")
ivan      = create_user(email: "ivan@example.com",  name: "Ivan Petrov",   role_name: "teacher",     locale: "ru", country: "RU")
ana       = create_user(email: "ana@example.com",   name: "Ana Kowalski",  role_name: "student",     locale: "es", country: "RU")
pedro     = create_user(email: "pedro@example.com", name: "Pedro Lopez",   role_name: "student",     locale: "es", country: "CO")

puts "  ✅ 5 named users (password: password123)"

# ──────────────────────────────────────────────────
# 2. Extra coordinators
# ──────────────────────────────────────────────────
puts "👤 Extra coordinators..."

extra_coordinators = 2.times.map do
  create_user(
    email: Faker::Internet.unique.email,
    name:  Faker::Name.name,
    role_name: "coordinator",
    locale: "es",
    country: "ES"
  )
end
coordinators = [ maria ] + extra_coordinators
puts "  ✅ #{coordinators.size} coordinators total"

# ──────────────────────────────────────────────────
# 3. Extra teachers
# ──────────────────────────────────────────────────
puts "👤 Extra teachers..."

extra_teachers = 2.times.map do
  create_user(
    email: Faker::Internet.unique.email,
    name:  Faker::Name.name,
    role_name: "teacher",
    locale: [ "es", "ru", "en" ].sample,
    country: [ "ES", "RU", "UA" ].sample
  )
end
teachers = [ ivan ] + extra_teachers
puts "  ✅ #{teachers.size} teachers total"

# ──────────────────────────────────────────────────
# 4. Students (20 total incl. ana & pedro)
# ──────────────────────────────────────────────────
puts "👤 Students..."

extra_students = 18.times.map do
  create_user(
    email: Faker::Internet.unique.email,
    name:  Faker::Name.name,
    role_name: "student",
    locale: [ "es", "ru", "en" ].sample,
    country: COUNTRIES.sample
  )
end
students = [ ana, pedro ] + extra_students
puts "  ✅ #{students.size} students total"

# ──────────────────────────────────────────────────
# 5. Teacher-student assignments
# ──────────────────────────────────────────────────
puts "📎 Teacher-student assignments..."

assignments_created = 0
students.each_with_index do |student, i|
  teacher = teachers[i % teachers.size]
  next if TeacherStudent.exists?(teacher_id: teacher.id, student_id: student.id)

  ts = TeacherStudent.create!(teacher_id: teacher.id, student_id: student.id, assigned_by: maria.id)

  # Each pair gets a conversation
  unless Conversation.exists?(teacher_student_id: ts.id)
    conv = Conversation.create!(teacher_student_id: ts.id)
    conv.add_participant!(teacher)
    conv.add_participant!(student)

    # A few messages
    rand(2..5).times do
      sender = [ teacher, student ].sample
      Message.create!(
        conversation: conv,
        user: sender,
        body: sender == teacher ? COORDINATOR_MESSAGES.sample : STUDENT_MESSAGES.sample,
        created_at: Faker::Time.between(from: 3.months.ago, to: Time.current)
      )
    end
  end

  assignments_created += 1
end
puts "  ✅ #{assignments_created} assignments + conversations"

# ──────────────────────────────────────────────────
# 6. Lessons (past + upcoming)
# ──────────────────────────────────────────────────
puts "📅 Lessons..."

lessons_created = 0
TeacherStudent.all.each do |ts|
  # 3-6 past lessons
  rand(3..6).times do
    scheduled = Faker::Time.between(from: 6.months.ago, to: 1.day.ago)
    status = [ "completed", "completed", "completed", "cancelled" ].sample
    Lesson.create!(
      teacher_id: ts.teacher_id,
      student_id: ts.student_id,
      scheduled_at: scheduled,
      duration_minutes: [ 60, 90 ].sample,
      status: status,
      notes: status == "cancelled" ? "Cancelado por el estudiante." : Faker::Lorem.sentence(word_count: 8)
    ) rescue nil
    lessons_created += 1
  end

  # 1-2 upcoming lessons
  rand(1..2).times do
    scheduled = Faker::Time.between(from: 1.day.from_now, to: 30.days.from_now)
    Lesson.new(
      teacher_id: ts.teacher_id,
      student_id: ts.student_id,
      scheduled_at: scheduled,
      duration_minutes: 60,
      status: "scheduled"
    ).save(validate: false)  # skip future-only validation for seed
    lessons_created += 1
  end
end
puts "  ✅ #{lessons_created} lessons"

# ──────────────────────────────────────────────────
# 7. Homologation Requests (spread over 12 months)
# ──────────────────────────────────────────────────
puts "📄 Homologation requests..."

subjects = [
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
  "Reconocimiento de Licenciatura en Letras",
]

requests_created = 0
coordinator_cycle = coordinators.cycle

students.each do |student|
  # Each student has 1-3 requests
  rand(1..3).times do
    status = REQUEST_STATUSES_WEIGHTED.sample
    coordinator = coordinator_cycle.next
    created = Faker::Time.between(from: 11.months.ago, to: 1.week.ago)

    req = HomologationRequest.new(
      user: student,
      coordinator: coordinator,
      subject: subjects.sample,
      service_type: SERVICE_TYPES.sample,
      description: Faker::Lorem.paragraph(sentence_count: 3),
      education_system: EDU_SYSTEMS.sample,
      studies_finished: [ "yes", "yes", "in_progress" ].sample,
      study_type_spain: STUDY_TYPES.sample,
      studies_spain: "yes",
      university: UNIVERSITIES.sample,
      referral_source: REFERRALS.sample,
      language_knowledge: LANG_LEVELS.sample,
      language_certificate: LANG_CERTS.sample,
      identity_card: Faker::IdNumber.spanish_citizen_number,
      passport: "#{("A".."Z").to_a.sample}#{Faker::Number.number(digits: 7)}",
      privacy_accepted: true,
      status: status,
      status_changed_at: created + rand(1..30).days,
      status_changed_by: coordinator.id,
      created_at: created,
      updated_at: created + rand(1..45).days
    )

    # Set payment fields for confirmed/later statuses
    if %w[payment_confirmed in_progress resolved closed].include?(status)
      req.payment_amount = [ 250, 350, 450, 550, 650 ].sample
      req.payment_confirmed_at = created + rand(10..30).days
      req.payment_confirmed_by = coordinator.id
    end

    # Some synced to AmoCRM
    if %w[in_progress resolved].include?(status) && rand < 0.7
      req.amo_crm_lead_id = Faker::Number.number(digits: 8).to_s
      req.amo_crm_synced_at = req.payment_confirmed_at&.+ rand(1..3).hours
    end

    # A few with sync errors
    if rand < 0.08
      req.amo_crm_sync_error = "Connection timeout: AmoCRM API unreachable"
    end

    req.save(validate: false)  # bypass status machine for seed data
    requests_created += 1

    # Create conversation for submitted+ requests
    if req.status != "draft" && req.conversation.nil?
      conv = Conversation.create!(homologation_request: req)
      conv.add_participant!(student)
      conv.add_participant!(coordinator)

      # Realistic back-and-forth messages
      msg_count = case status
      when "submitted"            then rand(0..2)
      when "in_review"            then rand(1..3)
      when "awaiting_reply"       then rand(2..5)
      when "awaiting_payment"     then rand(3..6)
      when "payment_confirmed",
           "in_progress"          then rand(4..8)
      when "resolved", "closed"   then rand(5..10)
      else 0
      end

      msg_time = created + 1.hour
      msg_count.times do |i|
        sender = i.even? ? coordinator : student
        body = sender == coordinator ? COORDINATOR_MESSAGES.sample : STUDENT_MESSAGES.sample
        msg_time += rand(1..72).hours
        break if msg_time > Time.current
        Message.create!(
          conversation: conv,
          user: sender,
          body: body,
          created_at: msg_time
        )
      end
    end
  end
end

puts "  ✅ #{requests_created} requests created"

# ──────────────────────────────────────────────────
# 8. Notifications
# ──────────────────────────────────────────────────
puts "🔔 Notifications..."

notif_count = 0
HomologationRequest.last(15).each do |req|
  # Unread notification for student
  Notification.find_or_create_by!(
    user: req.user,
    notifiable: req,
    title: "Estado actualizado: #{req.status}"
  ) do |n|
    n.read_at = rand < 0.4 ? Faker::Time.between(from: req.updated_at, to: Time.current) : nil
    n.created_at = req.updated_at
  end
  notif_count += 1

  # Notification for coordinator
  Notification.find_or_create_by!(
    user: req.coordinator,
    notifiable: req,
    title: "Nueva solicitud de #{req.user.name}"
  ) do |n|
    n.read_at = rand < 0.7 ? Faker::Time.between(from: req.created_at, to: Time.current) : nil
    n.created_at = req.created_at
  end
  notif_count += 1
end
puts "  ✅ #{notif_count} notifications"

# ──────────────────────────────────────────────────
# Summary
# ──────────────────────────────────────────────────
puts <<~SUMMARY

  ✅ Development seed complete!

  👥 Users:
     super_admin  boss@example.com     / password123
     coordinator  maria@example.com    / password123
     teacher      ivan@example.com     / password123
     student      ana@example.com      / password123
     student      pedro@example.com    / password123

  📊 Stats:
     Users:    #{User.count}
     Requests: #{HomologationRequest.count} (#{HomologationRequest.where.not(amo_crm_sync_error: nil).count} with sync errors)
     Lessons:  #{Lesson.count}
     Messages: #{Message.count}
     Notifs:   #{Notification.count}

SUMMARY
