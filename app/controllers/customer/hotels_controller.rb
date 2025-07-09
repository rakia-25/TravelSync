class Customer::HotelsController < ApplicationController
  layout 'customer'
  before_action :authenticate_user!
    def index
      @hotels = Hotel.includes(:rooms).where.not(rooms: { id: nil }).order(created_at: :desc)
      render "customer/hotels/index"
  
    end
  
    def show
      @hotel = Hotel.find(params[:id])
      @provider = @hotel.provider
      @rooms = @hotel.rooms.order(:created_at)
      render "customer/hotels/show"
    end
end
  