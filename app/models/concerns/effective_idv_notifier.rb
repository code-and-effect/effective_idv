# EffectiveIdvUser
#
# Mark your notifier model with
# include EffectiveIdvNotifier

module EffectiveIdvNotifier
  extend ActiveSupport::Concern

  module ClassMethods
    def effective_idv_notifier?; true; end
  end

  # Instance Methods
  def resource_scope
    raise('to be implemented by including class')
    # User.all
  end

  def notify!
    raise('to be implemented by including class')
    #notify_never_submitted
    #notify_expiring_soon
  end

  def send_email(email, user)
    EffectiveIdv.send_email(email, user)
  end

  def notify_never_submitted
    puts 'Sending never submitted emails'

    users = resource_scope.identity_verification_never_submitted

    users.find_each do |user|
      # Sanity check
      next unless user.identity_verification_never_submitted?

      print '.'

      send_email(:identity_verification_never_submitted, user)
    end

    puts 'All Done'
  end

  def notify_expiring_soon(date: nil)
    puts 'Sending expiring soon emails'

    date ||= EffectiveIdv.IdentityVerification.expiring_soon_date()

    users = resource_scope.identity_verification_expiring_soon(date)

    users.find_each do |user|
      # Double check incase they have multiple IDVs at once.
      next unless user.identity_verification_expiring_soon?(date)

      # We only want to send the email when its exactly this far away
      next unless user.identity_verification_expiry_date == date

      print '.'

      send_email(:identity_verification_expiring_soon, user)
    end

    puts 'All Done'
  end

end
