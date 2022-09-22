module EffectiveIdvTestBuilder

  def create_user!
    build_user.tap { |user| user.save! }
  end

  def build_user
    @user_index ||= 0
    @user_index += 1

    User.new(
      email: "user#{@user_index}@example.com",
      password: 'rubicon2020',
      password_confirmation: 'rubicon2020',
      first_name: 'Test',
      last_name: 'User'
    )
  end

  def build_user_with_address
    user = build_user()

    user.addresses.build(
      addressable: user,
      category: 'billing',
      full_name: 'Test User',
      address1: '1234 Fake Street',
      city: 'Victoria',
      state_code: 'BC',
      country_code: 'CA',
      postal_code: 'H0H0H0'
    )

    user.save!
    user
  end

  def build_identity_verification(user: nil)
    user ||= build_user()

    idv = EffectiveIdv.IdentityVerification.new(user: user)

    idv.assign_attributes(
      legal_name: 'Legal Name',
      date_of_birth: (Time.zone.now - 20.years),
      expiry_date: (Time.zone.now + 1.year)
    )

    idv
  end

  def build_submitted_identity_verification(user: nil)
    idv = build_identity_verification(user: user)

    idv.photo.attach(io: StringIO.new('asdf'), filename: 'photo.jpg', content_type: 'image/jpg', identify: false)
    idv.submit!

    idv
  end


end
