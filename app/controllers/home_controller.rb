class HomeController < ApplicationController
    layout 'customer'
    def index
    @hotels = Hotel.includes(:rooms).where.not(rooms: { id: nil }).order(created_at: :desc).limit(3)
    @trips = Trip.where("departureDate >= ?", Date.today).limit(3)
    @cars = Car.limit(3)      
    end
    
end
