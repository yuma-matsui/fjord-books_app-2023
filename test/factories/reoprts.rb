# frozen_string_literal: true

FactoryBot.define do
  factory :report do
    title   { 'My report' }
    content { 'My first report.' }
    user
  end
end
