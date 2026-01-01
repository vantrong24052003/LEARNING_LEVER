FactoryBot.define do
  factory :post do
    title { FFaker::Book.title }
    status { "draft" }
    user
  end
end
