# EffectiveIdvUser
#
# Mark your user model with effective_idv_user

module EffectiveIdvUser
  extend ActiveSupport::Concern

  module Base
    def effective_idv_user
      include ::EffectiveIdvUser
    end
  end

  included do
    # App scoped
    has_many :identity_verifications, -> { EffectiveIdv.IdentityVerification.sorted }, inverse_of: :user, as: :user
    accepts_nested_attributes_for :identity_verifications

    scope :identity_verification_valid, -> {
      idvs = EffectiveIdv.IdentityVerification.valid.where(user_type: name)
      where(id: idvs.select('user_id'))
    }

    scope :identity_verification_expired, -> {
      valid = EffectiveIdv.IdentityVerification.valid.where(user_type: name)
      expired = EffectiveIdv.IdentityVerification.expired.where(user_type: name)

      where(id: expired.select('user_id')).where.not(id: valid.select('user_id'))
    }

    scope :identity_verification_expiring_soon, -> (date = nil) {
      idvs = EffectiveIdv.IdentityVerification.expiring_soon(date).where(user_type: name)
      where(id: idvs.select('user_id'))
    }

    scope :identity_verification_never_submitted, -> {
      idvs = EffectiveIdv.IdentityVerification.was_submitted.where(user_type: name)
      where.not(id: idvs.select('user_id'))
    }

  end

  module ClassMethods
    def effective_idv_user?; true; end

    def identity_verification_search_scopes
      ['Valid', 'Expired', 'Expiring Soon', 'Never Submitted']
    end
  end

  def identity_verification_status
    if identity_verification_expired?
      'Expired'
    elsif identity_verification_expiring_soon?
      'Expiring Soon'
    elsif identity_verification_valid?
      'Valid'
    elsif was_submitted_identity_verifications.blank?
      'Never Submitted'
    elsif submitted_identity_verifications.present?
      'Ready to Approve'
    else
      'Invalid'
    end
  end

  # Plurals
  def submitted_identity_verifications
    identity_verifications.select(&:submitted?)
  end

  def was_submitted_identity_verifications
    identity_verifications.select(&:was_submitted?)
  end

  def approved_identity_verifications
    identity_verifications.select(&:approved?)
  end

  # Singular
  def identity_verification_expiry_date
    approved_identity_verifications.max { |idv| idv.expiry_date }.try(:expiry_date)
  end

  # Has at least one non expired identity validation
  def identity_verification_valid?
    return false if approved_identity_verifications.blank?
    identity_verification_expiry_date > Time.zone.now.to_date
  end

  def identity_verification_expired?
    return false if approved_identity_verifications.blank?
    identity_verification_expiry_date <= Time.zone.now.to_date
  end

  def identity_verification_expiring_soon?(date = nil)
    return false if approved_identity_verifications.blank?

    date ||= EffectiveIdv.IdentityVerification.expiring_soon_date()
    raise("expected a future date got #{date || 'nil'}") unless date.respond_to?(:strftime) && date > Time.zone.now

    identity_verification_expiry_date <= date
  end

  def identity_verification_never_submitted?
    was_submitted_identity_verifications.blank?
  end

  def identity_verification_approved_at
    approved_identity_verifications.max { |idv| idv.approved_at }.try(:approved_at)
  end

end
