# frozen_string_literal: true

Rails.application.routes.draw do
  mount EffectiveIdv::Engine => '/', as: 'effective_idv'
end

EffectiveIdv::Engine.routes.draw do
  # Public routes
  scope module: 'effective' do
    resources :identity_verifications, only: [:new, :show, :destroy] do
      resources :build, controller: :identity_verifications, only: [:show, :update]
    end
  end

  namespace :admin do
    resources :identity_verifications, except: [:new, :create]
  end

end
