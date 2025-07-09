class Provider::ReservationsController < ApplicationController
    before_action :authenticate_user!
    before_action :check_provider
  
    def index
        provider = current_user.provider
      
        # On récupère les réservations liées aux chambres de ses hôtels
        hotel_room_ids = Room.joins(:hotel).where(hotels: { provider_id: provider.id }).pluck(:id)
        room_reservations = Reservation.where(reservable_type: "Room", reservable_id: hotel_room_ids)
      
        # On récupère les réservations de ses voitures
        car_ids = Car.where(provider_id: provider.id).pluck(:id)
        car_reservations = Reservation.where(reservable_type: "Car", reservable_id: car_ids)
      
        # On récupère les réservations de ses voyages
        trip_ids = Trip.where(provider_id: provider.id).pluck(:id)
        trip_reservations = Reservation.where(reservable_type: "Trip", reservable_id: trip_ids)
      
        # On regroupe toutes les réservations
        @reservations = room_reservations.or(car_reservations).or(trip_reservations).order(created_at: :desc)
      end
      
  
    def update
      @reservation = Reservation.find(params[:id])
      if params[:status].in?(%w[confirmed rejected])
        @reservation.update(status: params[:status])
        redirect_back fallback_location: provider_reservations_path, notice: "Réservation mise à jour"
      else
        redirect_back fallback_location: provider_reservations_path, alert: "Statut invalide"
      end
    end
  
    private
  
    def check_provider
      redirect_to root_path unless current_user.provider.present?
    end
  end
  