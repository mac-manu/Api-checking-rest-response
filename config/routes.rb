# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'travel#index'
  get '/search' => 'travel#search'
end
