# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :code_commands, only: [] do
        collection do
          post :generate_tree
          post :execute
        end
      end

      resources :courses do
        member do
          post :start
          get :progress
        end

        resources :lessons
        resources :reviews
      end

      resources :users, except: %i[create] do
        collection do
          post :register
          post :login
          post :logout
          get :current_user
        end
      end

      resources :certificates, only: %i[index show]
    end
  end
end
