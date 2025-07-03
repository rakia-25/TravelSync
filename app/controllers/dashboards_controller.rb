class DashboardsController < ApplicationController
    before_action :authenticate_user!
    before_action :redirect_by_role

    def provider
        @provider=current_user.provider
        if @provider.hotelier?
            render "dashboards/hotelier"
        elsif @provider.rental_agency?
            render "dashboards/rental_agency"
        elsif @provider.travel_agency?
            render "dashboards/travel_agency"
        else
            redirect_to root_path, alert: "Type de prestataire non reconnu."
        end
    end

    def redirect_by_role
        if current_user.provider?
          if current_user.provider.nil?
            redirect_to new_provider_path, alert: "Complétez votre profil prestataire d'abord." and
            return
          end
        else
          redirect_to root_path, alert: "Accès réservé aux prestataires ou administrateurs." and return
        end
    end
end
