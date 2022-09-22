require 'test_helper'

class IdvTest < ActiveSupport::TestCase
  test 'user factory' do
    user = build_user()
    assert user.valid?
  end

  test 'identity verification factory' do
    identity_verification = build_identity_verification()
    assert identity_verification.valid?
    assert identity_verification.draft?
  end

  test 'submitted identity verification factory' do
    identity_verification = build_submitted_identity_verification()
    assert identity_verification.valid?
    assert identity_verification.submitted?
    assert identity_verification.in_progress?
  end

end
