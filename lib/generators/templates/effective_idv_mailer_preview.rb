# Visit http://localhost:3000/rails/mailers
class EffectiveIdvMailerPreview < ActionMailer::Preview

  def identity_verification_submitted
    idv = build_identity_verification()
    EffectiveIdv.mailer_class.identity_verification_submitted(idv)
  end

  def identity_verification_submitted_to_admin
    idv = build_identity_verification()
    EffectiveIdv.mailer_class.identity_verification_submitted_to_admin(idv)
  end

  def identity_verification_approved
    idv = build_identity_verification()
    idv.approved_at = Time.zone.now
    EffectiveIdv.mailer_class.identity_verification_approved(idv)
  end

  def identity_verification_declined
    idv = build_identity_verification()
    idv.declined_reason = 'The Declined Reason'
    idv.declined_at = Time.zone.now
    EffectiveIdv.mailer_class.identity_verification_declined(idv)
  end

  def identity_verification_never_submitted
    user = build_user()
    EffectiveIdv.mailer_class.identity_verification_never_submitted(user)
  end

  def identity_verification_expiring_soon
    user = build_user()
    EffectiveIdv.mailer_class.identity_verification_expiring_soon(user)
  end

  protected

  def build_user
    User.new(email: 'buyer@website.com').tap do |user|
      user.name = 'Valued Customer' if user.respond_to?(:name=)
      user.full_name = 'Valued Customer' if user.respond_to?(:full_name=)

      if user.respond_to?(:first_name=) && user.respond_to?(:last_name=)
        user.first_name = 'Valued'
        user.last_name = 'Customer'
      end
    end
  end

  def build_identity_verification
    EffectiveIdv.IdentityVerification.new(
      user: build_user,
      expiry_date: (Time.zone.now + 1.day),
      token: 'asdf',
      status: 'submitted',
      status_steps: { submitted: Time.zone.now },
      submitted_at: Time.zone.now
    )
  end

end
