Rails.application.routes.draw do
  use_doorkeeper_openid_connect

  use_doorkeeper do
    controllers authorizations: 'doorkeeper/caucision_authorizations'
  end

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', sessions: 'users/sessions' }

  resources :projects do
    member do
      post :import, to: 'projects#import_data'
      post :causal_graph, to: 'projects#import_causal_graph'
      get :table
      get :graph, to: 'projects#query_graph'
    end

    resources :graphs, shallow: true
    resources :campaigns, shallow: true
  end
end
