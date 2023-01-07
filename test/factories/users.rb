# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email                 { Faker::Internet.email(domain: 'example') }
    name                  { Faker::Internet.username }
    postal_code           { Faker::Address.zip_code }
    address               { Faker::Address.full_address }
    self_introduction     { Faker::Lorem.sentence }
    password              { Faker::Internet.password(min_length: 6) }
    password_confirmation { password }
  end
end
