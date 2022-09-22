# frozen_string_literal: true

# EffectiveIdvIdentityVerification
#
# Mark your owner model with effective_idv_identity_verification to get all the includes

module EffectiveIdvIdentityVerification
  extend ActiveSupport::Concern

  module Base
    def effective_idv_identity_verification
      include ::EffectiveIdvIdentityVerification
    end
  end

  module ClassMethods
    def effective_idv_identity_verification?; true; end

    # For effective_category_applicant_wizard_steps_collection
    def required_wizard_steps
      [:start, :identity, :review, :submitted]
    end
  end

  included do
    acts_as_email_form
    acts_as_tokened

    log_changes(except: :wizard_steps) if respond_to?(:log_changes)

    acts_as_statused(
      :draft,       # Just Started
      :submitted,   # All Done
      :declined,
      :approved
    )

    acts_as_wizard(
      start: 'Start',
      identity: 'Identity Verification',
      review: 'Review',
      submitted: 'Submitted'
    )


    attr_accessor :admin_process_action

    # Application Namespace
    belongs_to :user, polymorphic: true
    accepts_nested_attributes_for :user

    has_one_attached :photo

    effective_resource do
      identity_verification_type      :string       # Unused

      # Fields Collected
      legal_name            :string
      date_of_birth         :date
      expiry_date           :date

      # Acts as Statused
      status                 :string, permitted: false
      status_steps           :text, permitted: false

      # Dates
      submitted_at           :datetime, permitted: false
      approved_at            :datetime, permitted: false

      # Declined
      declined_at            :datetime, permitted: false
      declined_reason        :text

      # Acts as Wizard
      wizard_steps           :text, permitted: false

      # Acts as Tokened
      token                  :string

      notes                  :text                  # For admin maybe

      timestamps
    end

    scope :in_progress, -> { where(status: :draft) }
    scope :done, -> { where(status: [:approved, :declined]) }
    scope :not_draft, -> { where.not(status: :draft) }

    scope :sorted, -> { order(:id) }
    scope :deep, -> { includes(:user) }

    scope :for, -> (user) {
      raise('expected a effective idv user') unless user.class.try(:effective_idv_user?)
      where(user: user)
    }

    with_options(if: -> { submitted? }) do
      validates :photo, presence: true
      validates :legal_name, presence: true
      validates :date_of_birth, presence: true
      validates :expiry_date, presence: true

      validate do
        self.errors.add(:photo, 'must be an image') if photo.attached? && !photo.image?
      end
    end

    # Admin Decline
    validates :declined_reason, presence: true, if: -> { declined? }

    def to_s
      legal_name.presence || 'identity verification'
    end

    def in_progress?
      draft? || submitted?
    end

    def done?
      approved? || declined?
    end

    def can_visit_step?(step)
      return (step == :submitted) if was_submitted?
      can_revisit_completed_steps(step)
    end

    def status_label
      (status_was || status).to_s.gsub('_', ' ')
    end

    def summary
      case status_was
      when 'draft'
        "Identity verification has not yet been submitted"
      when 'submitted'
        "Identity verification has been submitted. Waiting on approval."
      when 'approved'
        "The identity verification has been approved. All done."
      when 'declined'
        "This identity verification has been declined."
      else
        raise("unexpected status #{status}")
      end.html_safe
    end

    # For use in the summary partials. Does not include summary.
    def render_steps
      blacklist = [:start, :review, :summary]
      (required_steps - blacklist).select { |step| has_completed_step?(step) }
    end

    def expired?
      return false if expiry_date.blank?
      expiry_date <= Time.zone.now.to_date
    end

    # Called by the form
    def review!
      submit!
    end

    def submit!
      submitted!

      after_commit { send_email(:identity_verification_submitted) }
      true
    end

    def approve!
      approved!

      after_commit { send_email(:identity_verification_approved) }
      true
    end

    def decline!
      declined!

      after_commit { send_email(:identity_verification_declined) }
      true
    end

    private

    def send_email(email)
      EffectiveIdv.send_email(email, self, email_form_params) unless email_form_skip?
    end

  end
end
