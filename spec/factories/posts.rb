# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    title { FFaker::Book.title }
    status { "draft" }
    user
  end
end
