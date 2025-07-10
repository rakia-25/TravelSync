class Trip < ApplicationRecord
  # belongs_to :provider
  # has_many :hotel_trips
  # has_many :hotels, through: :hotel_trips
  has_many :reservations, as: :reservable, dependent: :destroy
  has_many_attached :images
   validates :title, :theme, :program, :duration,
            :departureDate, :returnDate,
            :departureCity, :destinationCity, presence: true

  validate :return_after_departure

  private

  def return_after_departure
    if returnDate.present? && departureDate.present? && returnDate < departureDate
      errors.add(:returnDate, "doit être après la date de départ")
    end
  end
end
