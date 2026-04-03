FactoryBot.define do
  factory :homologation_request do
    association :user, :student
    subject { Faker::Lorem.sentence(word_count: 3) }
    service_type { "equivalencia" }
    status { "draft" }
    privacy_accepted { false }

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
      # For submitted requests, the after_save callback auto-creates the conversation.
      # This trait ensures conversation + participant exist regardless of status.
      after(:create) do |request|
        unless request.conversation
          conv = Conversation.create!(homologation_request: request)
          conv.conversation_participants.create!(user: request.user)
        end
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
