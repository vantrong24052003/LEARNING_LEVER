# frozen_string_literal: true

class Wallet < ApplicationRecord
  belongs_to :user
  validates :user_id, uniqueness: true

  self.locking_column = :lock_version
end
