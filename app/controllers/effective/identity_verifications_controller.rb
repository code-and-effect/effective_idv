module Effective
  class IdentityVerificationsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)

    include Effective::WizardController

    resource_scope -> { EffectiveIdv.IdentityVerification.deep.where(user: current_user) }

  end
end
