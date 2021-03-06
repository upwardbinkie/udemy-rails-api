# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  post "login", to: "access_tokens#create"
  delete "logout", to: "access_tokens#destroy"
  resources :articles, only: [:index, :show, :create]
end
