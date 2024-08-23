class ApplicationController < ActionController::Base
    include ApplicationHelper
    before_action :configure_permitted_parameters, if: :devise_controller? 
    before_action :search 

    def home 
    end 

    def search
      @article = Article.new
      @search = Article.ransack(params[:q])
      if params[:q].present?
        @search_articles = @search.result(distinct: true).order(created_at: :desc).page(params[:page])
      end 
    end 

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
