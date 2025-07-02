class HotelTrip < ApplicationRecord
  belongs_to :hotel
  belongs_to :trip
end
