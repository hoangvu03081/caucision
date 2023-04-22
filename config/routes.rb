Rails.application.routes.draw do
  use_doorkeeper_openid_connect

  use_doorkeeper do
    controllers authorizations: 'doorkeeper/caucision_authorizations'
  end

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', sessions: 'users/sessions' }

  # devise_scope :user do
  #   delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  # end

  get 'temporary', action: :index, controller: 'temporary'

  resources :projects do
    member do
      post :import, to: 'projects#import_data'
      post :causal_graph, to: 'projects#import_causal_graph'
      get :table
    end
  end
end
