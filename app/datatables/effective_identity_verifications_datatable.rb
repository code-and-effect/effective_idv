# Dashboard Identity Verifications
class EffectiveIdentityVerificationsDatatable < Effective::Datatable
  datatable do
    order :created_at

    col :id, visible: false

    col :created_at, label: 'Created', as: :date, visible: false
    col :updated_at, label: 'Updated', as: :date, visible: false

    col :submitted_at, label: 'Submitted', as: :date
    col :approved_at, label: 'Approved', as: :date

    col :expiry_date, label: 'Expires', as: :date do |identity_verification|
      if identity_verification.expired?
        identity_verification.expiry_date.strftime('%F') + ' ' + badges('expired')
      else
        identity_verification.expiry_date.strftime('%F')
      end
    end

    actions_col(show: false) do |identity_verification|
      if identity_verification.draft?
        dropdown_link_to('Continue', effective_idv.identity_verification_build_path(identity_verification, identity_verification.next_step), 'data-turbolinks' => false)
        dropdown_link_to('Delete', effective_idv.identity_verification_path(identity_verification), 'data-confirm': "Really delete #{identity_verification}?", 'data-method': :delete)
      else
        dropdown_link_to('Show', effective_idv.identity_verification_path(identity_verification))
      end
    end
  end

  collection do
    EffectiveIdv.IdentityVerification.deep.for(current_user)
  end

end
