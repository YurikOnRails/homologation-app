FactoryBot.define do
  factory :user do
    name {
      locale = %i[ru es].sample
      prev = Faker::Config.locale
      Faker::Config.locale = locale
      n = Faker::Name.name
      Faker::Config.locale = prev
      n
    }
    email_address { Faker::Internet.unique.email }
    password { "password123" }
    locale { "es" }
    is_minor { false }
    notification_email { true }
    notification_telegram { false }
    sequence(:whatsapp) { |n| "+7900#{n.to_s.rjust(7, '0')}" }
    birthday { Faker::Date.birthday(min_age: 18, max_age: 40) }
    country { "RU" }
    has_homologation { true }
    has_education { false }

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
      country { %w[AR CO MX PE VE CU EC BO CL].sample }
    end
  end
end
