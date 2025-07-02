class Trip < ApplicationRecord
  belongs_to :provider
  has_many :hotel_trips
  has_many :hotels, through: :hotel_trips
end
