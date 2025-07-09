class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :reservable, polymorphic: true
  enum status: { pending: "pending", confirmed: "confirmed", rejected: "rejected", cancelled:"cancelled",paid: "paid"}, _default: "pending"
  with_options if: -> { reservable_type != "Trip" } do
    validates :start_date, presence: true
    validates :end_date, presence: true
  end
end
