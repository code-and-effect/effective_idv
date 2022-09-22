require 'test_helper'

class IdentityVerificationTest < ActiveSupport::TestCase
  test 'when submitted' do
    identity_verification = build_submitted_identity_verification()

    assert_email(count: 2) { build_submitted_identity_verification() }

    assert identity_verification.submitted?
    assert identity_verification.in_progress?
  end

  test 'approved' do
    identity_verification = build_submitted_identity_verification()

    assert_email { identity_verification.approve! }

    assert identity_verification.approved?
    assert identity_verification.done?
  end

  test 'declined' do
    identity_verification = build_submitted_identity_verification()

    identity_verification.declined_reason = 'Declined'
    assert_email { identity_verification.decline! }

    assert identity_verification.declined?
    assert identity_verification.done?
  end

end
