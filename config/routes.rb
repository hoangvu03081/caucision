Rails.application.routes.draw do
  use_doorkeeper_openid_connect

  use_doorkeeper do
    controllers authorizations: 'doorkeeper/caucision_authorizations'
  end

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', sessions: 'users/sessions' }

  get 'project_sample_dataset', to: 'projects#sample_dataset'
  resources :projects do
    member do
      post :import, to: 'projects#import_data'
      post :causal_graph, to: 'projects#import_causal_graph'
      get :table
      get :graph, to: 'projects#query_graph'
    end

    resources :graphs, only: [:index, :new, :create]
    resources :campaigns, only: [:index, :new, :create]
  end

  resources :campaigns, only: [:show, :update, :destroy] do
    member do
      post :import, to: 'campaigns#import_data'
      get :table
      get :graph, to: 'campaigns#query_graph'

      delete :optimization, to: 'campaigns#delete_optimization'
      get :optimization_table, to: 'campaigns#fetch_optimization_table'
      get :optimization_result, to: 'campaigns#download_optimization_result'
      post :optimization, to: 'campaigns#create_optimization'
    end

    resources :graphs, only: [:index, :new, :create]
  end

  resources :graphs, only: [:show, :update, :destroy]

  resources :notifications, only: [:index, :update]

  get :search, to: 'search#index'

  post '/internal/default_campaign', to: 'internal#create_default_campaign'
  post '/users/complete_tour_guide', to: 'users#complete_tour_guide'
  get '/healthcheck', to: 'healthcheck#index'
end
