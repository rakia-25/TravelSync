    class ProvidersController < ApplicationController
            before_action :authenticate_user!
            before_action :check_if_provider
            before_action :check_existing_provider_profile, only: [:new, :create]
            before_action :set_provider, only: [:show, :edit, :update, :destroy]
            
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
            def show
                
            end
            def edit
            end
            
            def update
                if @provider.update(provider_params)
                redirect_to dashboard_provider_path, notice: "Profil mis à jour avec succès"
                else
                render :edit
                end
            end
            
            def destroy
                @provider.destroy
                redirect_to root_path, notice: "Profil supprimé avec succès"
            end
            
            private
            def set_provider
                @provider = current_user.provider
                unless @provider
                  redirect_to new_provider_path, alert: "Vous devez créer un profil prestataire d'abord."
                end
              end
            def check_if_provider
                unless current_user.provider?
                    redirect_to root_path, notice: "Accés reservé aux prestataires"
                end
            end

            def check_existing_provider_profile
                if current_user.provider.present?
                redirect_to dashboard_provider_path, alert: "Vous avez déjà un profil prestataire."
                end
            end
        
            def provider_params
                params.require(:provider).permit(:business, :type_provider, :address)
            end
        
    end
