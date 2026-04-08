FactoryBot.define do
  factory :message do
    association :conversation
    association :user
    body { Faker::Lorem.paragraph(sentence_count: 2) }
  end
end
