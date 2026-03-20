class HomologationRequest < ApplicationRecord
  include Discardable

  class InvalidTransition < StandardError; end

  STATUSES = %w[draft submitted in_review awaiting_reply awaiting_payment payment_confirmed in_progress resolved closed].freeze

  VALID_TRANSITIONS = {
    "draft"             => %w[submitted],
    "submitted"         => %w[in_review],
    "in_review"         => %w[awaiting_reply awaiting_payment],
    "awaiting_reply"    => %w[in_review],
    "awaiting_payment"  => %w[payment_confirmed],
    "payment_confirmed" => %w[in_progress],
    "in_progress"       => %w[resolved closed]
  }.freeze

  belongs_to :user
  belongs_to :coordinator, class_name: "User", optional: true

  has_one :conversation, dependent: :destroy

  has_one_attached :application
  has_many_attached :originals
  has_many_attached :documents

  encrypts :identity_card, :passport

  validates :subject, presence: true
  validates :service_type, presence: true

  after_save :create_request_conversation!, if: -> { saved_change_to_status? && status == "submitted" }

  def transition_to!(new_status, changed_by:)
    allowed = VALID_TRANSITIONS[status] || []
    raise InvalidTransition, "Cannot transition from #{status} to #{new_status}" unless allowed.include?(new_status)

    attrs = { status: new_status, status_changed_at: Time.current, status_changed_by: changed_by.id }
    attrs[:payment_confirmed_at] = Time.current if new_status == "payment_confirmed"
    update!(attrs)

    if amo_crm_lead_id.present? && %w[in_progress resolved closed].include?(new_status)
      AmoCrmStatusSyncJob.perform_later(id)
    end
  end

  private

  def create_request_conversation!
    conv = Conversation.create!(homologation_request: self)
    conv.conversation_participants.create!(user: user)
    # Coordinator is added as participant when they first open the request (see controller)
  end
end
