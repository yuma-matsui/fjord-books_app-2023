# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com" }
    name                  { 'taro' }
    password              { 'Zwmh8X8KXjLgefgYnPqu' }
    password_confirmation { password }
  end
end
