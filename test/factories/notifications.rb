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
