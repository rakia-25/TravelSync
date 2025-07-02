class Provider < ApplicationRecord
  belongs_to :user
  has_many :hotels,dependent: :destroy
  has_many :trips,dependent: :destroy
end
