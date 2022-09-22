module Effective
  class IdentityVerification < ActiveRecord::Base
    self.table_name = EffectiveIdv.identity_verifications_table_name.to_s

    effective_idv_identity_verification
  end
end
