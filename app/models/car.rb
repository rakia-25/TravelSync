class Car < ApplicationRecord
  belongs_to :provider
  has_many :reservations, as: :reservable, dependent: :destroy
end
