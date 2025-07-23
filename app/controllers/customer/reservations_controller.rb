class Customer::ReservationsController < ApplicationController
  layout 'customer'
  before_action :authenticate_user!
  before_action :set_reservation, only: [:show, :edit, :update]

  def index
    @reservations = current_user.reservations.order(created_at: :desc)
  end

  def show
    @reservable = @reservation.reservable
  end

  def edit
    redirect_to users_reservations_path, alert: "Impossible de modifier cette réservation." unless @reservation.pending?
  end

  def update
    unless @reservation.pending?
      redirect_to users_reservation_path(@reservation), alert: "Impossible de modifier une réservation confirmée ou annulée." and return
    end
    if @reservation.pending? && @reservation.update(reservation_params)
      redirect_to users_reservation_path(@reservation), notice: "Réservation mise à jour avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end
 
  private
  def set_reservation
    @reservation = current_user.reservations.find(params[:id])
  end

  def reservation_params
    params.require(:reservation).permit(:start_date, :end_date, :status)
  end
  
end
