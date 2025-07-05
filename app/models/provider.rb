class Provider < ApplicationRecord
  belongs_to :user
  has_many :hotels,dependent: :destroy
  has_many :trips,dependent: :destroy
  enum :type_provider, {hotelier:"hotelier", rental_agency:"rental_agency",travel_agency:"travel_agency"}

end
