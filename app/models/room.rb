class Room < ApplicationRecord
  belongs_to :hotel
  validates :type_room, :price, presence: true
  validates :beds, numericality: { only_integer: true, greater_than: 0 }
end
