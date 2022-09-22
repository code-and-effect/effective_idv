module Admin
  class IdentityVerificationsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_idv) }

    include Effective::CrudController

    resource_scope -> { EffectiveIdv.IdentityVerification.deep.all }
    datatable -> { Admin::EffectiveIdentityVerificationsDatatable.new }

    submit :approve, 'Approve Identity Verification', redirect: :show, success: -> {
      [
        "Successfully approved #{resource}",
        ("and sent #{resource.user.email} a notification" unless resource.email_form_skip)
      ].compact.join(' ')
    }

    submit :decline, 'Decline Identity Verification', redirect: :show, success: -> {
      [
        "Successfully declined #{resource}",
        ("and sent #{resource.user.email} a notification" unless resource.email_form_skip)
      ].compact.join(' ')
    }

    private

    def permitted_params
      model = (params.key?(:effective_identity_verification) ? :effective_identity_verification : :identity_verification)
      params.require(model).permit!
    end

  end
end
