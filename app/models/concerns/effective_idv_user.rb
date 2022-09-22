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
  end

  module ClassMethods
    def effective_idv_user?; true; end
  end

end
