class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_one :wallet, dependent: :destroy
end
