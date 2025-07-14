class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :reservable, polymorphic: true

  enum status: { pending: "pending", confirmed: "confirmed", rejected: "rejected", cancelled:"cancelled", paid: "paid" }, _default: "pending"

  with_options if: -> { reservable_type != "Trip" } do
    validates :start_date, presence: true
    validates :end_date, presence: true
  end

  validate :end_date_after_start_date
  validate :start_date_cannot_be_in_the_past

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, "doit être après la date de début")
    end
  end

  def start_date_cannot_be_in_the_past
    return if start_date.blank?

    if start_date < Date.today
      errors.add(:start_date, "ne peut pas être dans le passé")
    end
  end
end
