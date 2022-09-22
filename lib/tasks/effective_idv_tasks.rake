namespace :effective_idv do

  # bundle exec rake effective_idv:seed
  task seed: :environment do
    load "#{__dir__}/../../db/seeds.rb"
  end

end
