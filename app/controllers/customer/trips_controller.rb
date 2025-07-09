class Customer::TripsController < ApplicationController
    layout 'customer'
    before_action :authenticate_user!
    def index
        @trips = Trip.order(created_at: :desc)
    end
  
    def show
        @trip = Trip.find(params[:id])
    end
end