module Admin
  class EffectiveIdentityVerificationsDatatable < Effective::Datatable
    filters do
      scope :not_draft, label: 'All'
      scope :in_progress, label: 'Open / Active'
      scope :done, label: 'Done'
      scope :draft
    end

    datatable do
      order :created_at

      col :id, visible: false
      col :token, visible: false

      col :created_at, label: 'Created', as: :date, visible: false
      col :updated_at, label: 'Updated', as: :date, visible: false

      col :status

      col :submitted_at, label: 'Submitted', as: :date
      col :approved_at, label: 'Approved', as: :date

      col :user

      col :expiry_date

      col :expired, label: 'Expired' do |identity_verification|
        badges('expired') if identity_verification.expired?
      end

      actions_col
    end

    collection do
      EffectiveIdv.IdentityVerification.deep.all
    end

  end
end
