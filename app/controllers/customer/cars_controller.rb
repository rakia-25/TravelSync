class Customer::CarsController < ApplicationController
    layout 'customer'
    before_action :authenticate_user!
    def index
        @cars = Car.where(available: true).order(created_at: :desc)
    end
  
    def show
        @car = Car.find(params[:id])
    end
  end
  