class Provider::RoomsController < ApplicationController
    layout "dashboard"
    before_action :set_hotel
    before_action :set_room, only: %i[edit update destroy show]
    def new
        @room = @hotel.rooms.build
    end
    def create
        @room = @hotel.rooms.build(room_params)
        if @room.save
            redirect_to provider_hotel_path(@hotel), notice: "Chambre ajoutée avec succès."
        else
            render :new, status: :unprocessable_entity
        end
    end

    def edit
    end

    def update
        if @room.update(room_params)
            redirect_to provider_hotel_path(@hotel), notice: "Chambre mise à jour."
        else
            render :edit
        end
    end
    def destroy
        @room.destroy
        redirect_to provider_hotel_path(@hotel), notice: "Chambre supprimée."
    end

    private

    def set_hotel
        @hotel = Hotel.find(params[:hotel_id])
    end

    def set_room
        @room = @hotel.rooms.find(params[:id])
    end

    def room_params
        params.require(:room).permit(:type_room, :price, :services, :available, :beds)
    end
end
