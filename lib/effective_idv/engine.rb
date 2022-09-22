module EffectiveIdv
  class Engine < ::Rails::Engine
    engine_name 'effective_idv'

    # Set up our default configuration options.
    initializer 'effective_idv.defaults', before: :load_config_initializers do |app|
      eval File.read("#{config.root}/config/effective_idv.rb")
    end

    # Include acts_as_addressable concern and allow any ActiveRecord object to call it
    # initializer 'effective_idv.active_record' do |app|
    #   app.config.to_prepare do
    #   end
    # end

    initializer 'effective_orders.active_record' do |app|
      ActiveSupport.on_load :active_record do
        ActiveRecord::Base.extend(EffectiveIdvIdentityVerification::Base)
        ActiveRecord::Base.extend(EffectiveIdvUser::Base)
      end
    end

  end
end
