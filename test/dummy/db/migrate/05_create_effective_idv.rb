class CreateEffectiveIdv < ActiveRecord::Migration[6.0]
  def change

    create_table :identity_verifications do |t|
      t.string :identity_verification_type

      t.string :user_type
      t.integer :user_id

      t.string :status
      t.string :status_steps

      t.text :wizard_steps

      t.string :token

      t.string :legal_name
      t.date :date_of_birth
      t.date :expiry_date

      t.datetime :submitted_at
      t.datetime :approved_at

      t.datetime :declined_at
      t.text :declined_reason

      t.text :notes

      t.timestamps
    end

  end
end