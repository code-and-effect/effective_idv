namespace :effective_idv do

  # bundle exec rake effective_idv:seed
  task seed: :environment do
    load "#{__dir__}/../../db/seeds.rb"
  end

  # rake effective_idv:notify
  desc 'Run daily to send identity verification reminders and notifications'
  task notify: :environment do
    begin
      if ActiveRecord::Base.connection.table_exists?(:identity_verifications)
        EffectiveLogger.info "Running effective_idv:notify scheduled task" if defined?(EffectiveLogger)
        EffectiveIdv.IdentityVerificationNotifier.notify!
      end
    rescue => e
      ExceptionNotifier.notify_exception(e) if defined?(ExceptionNotifier)
      puts "Error with notifications: #{e.errors.inspect}"
    end
  end

end
