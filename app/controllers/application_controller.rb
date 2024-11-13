class ApplicationController < ActionController::Base
  include ApplicationHelper
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :search

  def home; end

  def search
    @search = Article.ransack(params[:q])
    return unless params[:q].present?

    @search_articles = @search.result(distinct: true).order(created_at: :desc).paginate(page: params[:page],
                                                                                        per_page: 32)
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  private

  def logged_in_user
    return if user_signed_in?

    flash[:alert] = 'ログインしてください。'
    redirect_to login_url, status: :see_other
  end
end
