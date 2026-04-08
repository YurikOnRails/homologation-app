FactoryBot.define do
  factory :role do
    name { "student" }

    trait(:super_admin)  { name { "super_admin" } }
    trait(:coordinator)  { name { "coordinator" } }
    trait(:teacher)      { name { "teacher" } }
    trait(:student)      { name { "student" } }
  end
end
