class Hotel < ApplicationRecord
  belongs_to :provider
  has_many_attached :images
  has_many :rooms, dependent: :destroy
  has_many :hotel_trips
  has_many :trips, through: :hotel_trips
  validates :name, presence: true
  validates :stars, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

end
