class Car < ApplicationRecord
  belongs_to :provider
  has_many :reservations, as: :reservable, dependent: :destroy
  has_many_attached :images
end
