class ProvidersController < ApplicationController
    
        before_action :authenticate_user!
        before_action :check_if_provider
    
        def  new
            @provider = Provider.new
        end
    
        def create 
            @provider=current_user.build_provider(provider_params)
            if @provider.save
                redirect_to dashboard_provider_path, notice: "Profil créer avec succés"
            else
                render :new
            end
        end
        
        private
        def check_if_provider
            unless current_user.provider?
                redirect_to root_path, notice: "Accés reservé aux prestataires"
            end
        end
    
        def provider_params
            params.require(:provider).permit(:business, :type_provider, :address)
        end
    
end
