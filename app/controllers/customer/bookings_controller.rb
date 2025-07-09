class Customer::BookingsController < ApplicationController
  layout "customer"  
  before_action :authenticate_user!
    before_action :set_reservable

    def new
      @reservation = Reservation.new
    end
  
    def create
      if @reservable.is_a?(Trip)
        @reservation = @reservable.reservations.build(user: current_user)
      else
        @reservation = @reservable.reservations.build(reservation_params)
        @reservation.user = current_user
    
        if reservation_conflict?(@reservable, @reservation.start_date, @reservation.end_date)
          flash.now[:alert] = "Cet élément est déjà réservé pour les dates sélectionnées."
          render :new, status: :unprocessable_entity
          return
        end
      end
    
      if @reservation.save
        redirect_to customer_reservations_path, notice: "Réservation envoyée, en attente de confirmation."
      else
        render :new, status: :unprocessable_entity
      end
    end

  
    private
  
    def set_reservable
      if params[:room_id]
        @reservable = Room.find(params[:room_id])
      elsif params[:car_id]
        @reservable = Car.find(params[:car_id])
      elsif params[:trip_id]
        @reservable = Trip.find(params[:trip_id])
      else
        redirect_back fallback_location: root_path, alert: "Réservation invalide"
      end
    end
    def reservation_conflict?(reservable, start_date, end_date)
      reservable.reservations
        .where(status: "confirmed")
        .where("start_date < ? AND end_date > ?", end_date, start_date)
        .exists?
    end
  
    def reservation_params
      params.require(:reservation).permit(:start_date, :end_date)
    end
  end
  