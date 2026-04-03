FactoryBot.define do
  factory :conversation do
    trait :for_request do
      association :homologation_request
    end

    trait :for_teacher_student do
      association :teacher_student_link, factory: :teacher_student
    end
  end
end
