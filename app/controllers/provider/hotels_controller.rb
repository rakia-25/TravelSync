    class Provider::HotelsController < ApplicationController
        layout "dashboard"
        before_action :authenticate_user!
        before_action :set_provider
        before_action :check_hotelier
        before_action :set_hotel, only: [:show, :edit, :update, :destroy]
        def index
            @hotels = current_user.provider.hotels.order(created_at: :desc)
        end

        def new 
            @hotel = current_user.provider.hotels.new
        end

        def create 
            @hotel = current_user.provider.hotels.build(hotel_params)
        if @hotel.save
        redirect_to dashboard_provider_path, notice: "Hôtel créé avec succès."
        else
        render :new, status: :unprocessable_entity
        end
        end
def show 
end
        def edit

        end

        def update 
            if @hotel.update(hotel_params)
                redirect_to dashboard_provider_path, notice: "Hôtel mis à jour avec succès."
              else
                render :edit, status: :unprocessable_entity
              end
        end
        def destroy 
            @hotel.destroy
            redirect_to dashboard_provider_path, notice: "l'hotel a été supprimer avec succes"
        end

        def purge_image
            image = ActiveStorage::Attachment.find(params[:id])
            image.purge
            redirect_back fallback_location: provider_hotel_path(image.record), notice: "Image supprimée avec succès"
          end
        private
        def check_hotelier

            if current_user.provider.nil?
            redirect_to new_provider_path, alert: "Complétez d'abord votre profil de prestataire." and return
            end
        
            unless current_user.provider.hotelier?
            redirect_to root_path, alert: "Accès réservé aux hotelier" and return
            end
        end
        def set_provider
            @provider = current_user.provider
        end

        def set_hotel
            @provider=current_user.provider
            @hotel = current_user.provider.hotels.find(params[:id])
          end
        
        def hotel_params 
            params.require(:hotel).permit(:name, :stars, :description, :city, :address, :gps, :service, images: [])
        end
    end
