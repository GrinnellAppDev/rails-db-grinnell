# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/test', to: 'fetch#fetch'
  get '/api/v1/ios/fetch', to: 'fetch#fetch'
end
