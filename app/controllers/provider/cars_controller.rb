class Provider::CarsController < ApplicationController

  before_action :authenticate_user!
  before_action :check_rental_agency
  before_action :set_car, only: [:show, :edit, :update, :destroy]

  def show
  end

  def new
    @car = Car.new
  end

  def create
    @car = current_user.provider.cars.build(car_params)
    if @car.save
      redirect_to dashboard_provider_path, notice: "Voiture créée avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @car.update(car_params)
      redirect_to provider_car_path(@car), notice: "Voiture mise à jour avec succès."
    else
      render :edit
    end
  end

  def destroy
    @car.destroy
    redirect_to provider_cars_path, notice: "Voiture supprimée avec succès."
  end

  private

  def set_car
    @car = current_user.provider.cars.find(params[:id])
  end

  def car_params
    params.require(:car).permit(:brand, :name, :price, :options, :available, :model)
  end
  def check_rental_agency

    if current_user.provider.nil?
      redirect_to new_provider_path, alert: "Complétez d'abord votre profil de prestataire." and return
    end

    unless current_user.provider.rental_agency?
      redirect_to root_path, alert: "Accès réservé aux prestataires agence de location." and return
    end
  end
end

