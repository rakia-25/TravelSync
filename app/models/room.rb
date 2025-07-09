class Room < ApplicationRecord
  belongs_to :hotel
  has_many :reservations, as: :reservable, dependent: :destroy
  validates :type_room, :price, presence: true
  validates :beds, numericality: { only_integer: true, greater_than: 0 }
end
