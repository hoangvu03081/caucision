Rails.application.routes.draw do
  # use_doorkeeper_openid_connect
  use_doorkeeper do
    controllers authorizations: 'doorkeeper/caucision_authorizations'
  end

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  # devise_scope :user do
  #   delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  # end

  get 'temporary', action: :index, controller: 'temporary'
end
