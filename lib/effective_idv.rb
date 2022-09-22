require 'effective_resources'
require 'effective_datatables'
require 'effective_idv/engine'
require 'effective_idv/version'

module EffectiveIdv

  def self.config_keys
    [
      :identity_verifications_table_name, :identity_verification_class_name,
      :layout,
      :mailer, :parent_mailer, :deliver_method, :mailer_layout, :mailer_sender, :mailer_admin, :mailer_subject, :use_effective_email_templates
    ]
  end

  include EffectiveGem

  def self.IdentityVerification
    identity_verification_class_name&.constantize || Effective::IdentityVerification
  end

  def self.mailer_class
    mailer&.constantize || Effective::IdvMailer
  end

end
