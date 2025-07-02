class Hotel < ApplicationRecord
  belongs_to :provider
  has_many :rooms, dependent: :destroy
  has_many :hotel_trips
  has_many :trips, through: :hotel_trips

end
