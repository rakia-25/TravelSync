class Customer::PaymentsController < ApplicationController
  before_action :set_reservation
   skip_before_action :verify_authenticity_token, only: [:webhook]

  def create
    amount = @reservation.amount || 10000
    reference = "RES-#{@reservation.id}-#{Time.now.to_i}"

    response = IpayClient.create_payment(
      reference: reference,
      title: "Paiement Réservation ##{@reservation.id}",
      description: "Réservation effectuée le #{Time.current.strftime("%d/%m/%Y")}",
      amount: amount,
      currency: "XOF",
      callback_url: callback_customer_payments_url,
      return_url: customer_reservation_url(@reservation)
    )

    Rails.logger.info "iPay response: #{response.inspect}"

    if response.present? && response["status"] == "initiated" && response["page_url"].present?
      redirect_to response["page_url"]
    else
      flash[:alert] = "Erreur lors de la création du paiement. Veuillez réessayer."
      redirect_to customer_reservations_path
    end
  end

 

  def webhook
    Rails.logger.info "🎯 Webhook reçu de iPayMoney: #{params.inspect}"

    transaction_id = params[:transaction_id]
    status = params[:status]

    reservation = Reservation.find_by(reference: transaction_id)

    if reservation
      if status == "success"
        reservation.update(status: "paid", paid_at: Time.current)
      else
        reservation.update(status: "failed")
      end
    end

    render json: { message: "OK" }, status: :ok
  end
end

  private

  def set_reservation
    @reservation = Reservation.find(params[:reservation_id])
  end
end
