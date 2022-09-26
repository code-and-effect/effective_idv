module Effective
  class IdvMailer < EffectiveIdv.parent_mailer_class

    include EffectiveMailer
    include EffectiveEmailTemplatesMailer if EffectiveIdv.use_effective_email_templates

    def identity_verification_submitted(resource, opts = {})
      @assigns = assigns_for(resource)
      @identity_verification = resource

      subject = subject_for(__method__, "Identity Verification Submitted - #{resource}", resource, opts)
      headers = headers_for(resource, opts)

      mail(to: resource.user.email, subject: subject, **headers)
    end

    def identity_verification_submitted_to_admin(resource, opts = {})
      @assigns = assigns_for(resource)
      @identity_verification = resource

      subject = subject_for(__method__, "Identity Verification Submitted - #{resource}", resource, opts)
      headers = headers_for(resource, opts)

      mail(to: mailer_admin, subject: subject, **headers)
    end

    def identity_verification_approved(resource, opts = {})
      @assigns = assigns_for(resource)
      @identity_verification = resource

      subject = subject_for(__method__, "Identity Verification Approved - #{resource}", resource, opts)
      headers = headers_for(resource, opts)

      mail(to: resource.user.email, subject: subject, **headers)
    end

    def identity_verification_declined(resource, opts = {})
      @assigns = assigns_for(resource)
      @identity_verification = resource

      subject = subject_for(__method__, "Identity Verification Declined - #{resource}", resource, opts)
      headers = headers_for(resource, opts)

      mail(to: resource.user.email, subject: subject, **headers)
    end

    # User
    def identity_verification_never_submitted(resource, opts = {})
      @assigns = assigns_for(resource)
      @user = resource

      subject = subject_for(__method__, "Your Identity Verification is Required", resource, opts)
      headers = headers_for(resource, opts)

      mail(to: resource.user.email, subject: subject, message_stream: 'broadcast-stream', **headers)
    end

    def identity_verification_expiring_soon(resource, opts = {})
      @assigns = assigns_for(resource)
      @user = resource

      subject = subject_for(__method__, "Your Identity Verification Expires Soon", resource, opts)
      headers = headers_for(resource, opts)

      mail(to: resource.user.email, subject: subject, message_stream: 'broadcast-stream', **headers)
    end

    protected

    def assigns_for(resource)
      if resource.class.respond_to?(:effective_idv_identity_verification?)
        return identity_verification_assigns(resource).merge(user_assigns(resource.user))
      end

      if resource.class.respond_to?(:effective_idv_user?)
        return new_identity_verification_assigns.merge(user_assigns(resource))
      end

      raise('unexpected resource')
    end

    def identity_verification_assigns(identity_verification)
      raise('expected an identity_verification') unless identity_verification.class.respond_to?(:effective_idv_identity_verification?)

      values = {
        date: (identity_verification.submitted_at || Time.zone.now).strftime('%F'),
        submitted_at: (identity_verification.submitted_at&.strftime('%F') || 'not submitted'),
        approved_at: (identity_verification.approved_at&.strftime('%F') || 'not approved'),

        url: effective_idv.identity_verification_url(identity_verification),
        admin_url: effective_idv.admin_identity_verification_url(identity_verification),

        # Optional
        declined_reason: identity_verification.declined_reason.presence,
      }.compact

      { identity_verification: values }
    end

    def new_identity_verification_assigns
      values = {
        url: effective_idv.new_identity_verification_url
      }

      { identity_verification: values }
    end

    def user_assigns(user)
      raise('expected a user') unless user.respond_to?(:email)

      values = {
        name: user.to_s,
        email: user.email
      }

      { user: values }
    end

  end
end
