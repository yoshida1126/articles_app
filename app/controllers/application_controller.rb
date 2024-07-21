class ApplicationController < ActionController::Base

    def home 
    end 

    include ApplicationHelper
    before_action :configure_permitted_parameters, if: :devise_controller? 

    protected 

    def configure_permitted_parameters 
        devise_parameter_sanitizer.permit(:sign_up, keys:[:name]) 
    end 

    private 

    def logged_in_user 
        unless user_signed_in? 
          flash[:alert] = "ログインしてください。" 
          redirect_to login_url, status: :see_other 
        end 
    end 
end
