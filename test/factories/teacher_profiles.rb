FactoryBot.define do
  factory :teacher_profile do
    association :user, :teacher
    level { "senior" }
    hourly_rate { 25.00 }
    permanent_meeting_link { Faker::Internet.url(host: "zoom.us") }
    bio { Faker::Lorem.paragraph }
  end
end
