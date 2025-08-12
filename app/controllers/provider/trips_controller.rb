class Provider::TripsController < ApplicationController
  layout "dashboard"
  before_action :authenticate_user!
   before_action :set_provider
  before_action :check_travel_agency
  before_action :set_trip, only: %i[show edit update destroy]

 def index
  @trips = current_user.provider.trips.order(created_at: :desc)
    
  end

  def show
   
  end

  def new
    @trip = Trip.new
  end

  def create
    @trip = current_user.provider.trips.build(trip_params)
    if @trip.save
      redirect_to dashboard_provider_path, notice: "Voyage créé"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    
  end

  def update
    if @trip.update(trip_params)
      redirect_to provider_trip_path(@trip), notice: "Voyage modifié"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @trip.destroy
    redirect_to provider_trips_path
  end

  private

  def set_provider
            @provider = current_user.provider
  end

  def set_trip
   @trip = current_user.provider.trips.find(params[:id])
  end

  def trip_params
    params.require(:trip).permit(
      :title, :theme, :program, :duration,
      :departureDate, :returnDate,
      :departureCity, :destinationCity,
      :price,
     images: []
    )
  end
  def check_travel_agency

    if current_user.provider.nil?
      redirect_to new_provider_path, alert: "Complétez d'abord votre profil de prestataire." and return
    end

    unless current_user.provider.travel_agency?
      redirect_to root_path, alert: "Accès réservé aux prestataires agence de voyage." and return
    end
  end
end
