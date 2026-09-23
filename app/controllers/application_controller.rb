class ApplicationController < ActionController::Base
  include ApplicationHelper
  before_action :configure_permitted_parameters, if: :devise_controller?

  def home; end

  rescue_from ActiveRecord::RecordNotFound, with: :render404
  rescue_from ActionController::RoutingError, with: :render_404

  def routing_error
    render404
  end

  def render404
    render template: 'static_pages/render404', status: 404, layout: 'static_page', content_type: 'text/html'
  end

  private

  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_root_path
    else
      root_path
    end
  end

  def logged_in_user
    return if user_signed_in?

    flash[:alert] = 'ログインしてください。'
    redirect_to login_url, status: :see_other
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def authorize_resource_owner(resource)
    unless resource.user == current_user
      flash[:alert] = "権限がありません。"
      redirect_to root_url, status: :see_other
    end
  end

  def authorize_user!
    if params[:user_id]
      @user = User.find_by(id: params[:user_id])
    else
      @user = User.find_by(id: params[:id])
    end

    unless @user == current_user
      redirect_to root_path, notice: "不正なアクセスです" and return
    end
  end

  def set_upload_quota_data
    return unless current_user

    service = UploadQuotaService.new(user: current_user)
    @max_size = service.max_size
    @remaining_mb = service.remaining_mb
  end

  def fetch_liked_article_ids(article_ids)
    return unless current_user
    
    current_user.likes
    .where(article_id: article_ids)
    .pluck(:article_id)
  end
end
