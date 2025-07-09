class Customer::MenuController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_customer
  
    def index
       
    end
  
    private
  
    def ensure_customer
      redirect_to root_path, alert: "Accès réservé aux clients." unless current_user.customer?
    end
end
