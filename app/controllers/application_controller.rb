class ApplicationController < ActionController::Base
  include ApplicationHelper
  before_action :configure_permitted_parameters, if: :devise_controller?

  def home; end

  def search
    @search_word = params[:q].values.compact.first.to_s

    if /\A#.+/ =~ @search_word
      @search_word = @search_word.sub(/^#/, '')
      @search_word.gsub!(" ", "")
      @search_word.gsub!("　", "")
      redirect_to tag_path(@search_word)
    else
      @target = params[:target] || 'article'

      case @target
      when 'article'
        search = Article.published.ransack(params[:q])
        @search_articles = search.result(distinct: true).order(created_at: :desc).paginate(page: params[:page],
                                                                                                 per_page: 30)
      when 'list'
        search = FavoriteArticleList.ransack(params[:q])
        @search_lists = search.result(distinct: true).order(created_at: :desc).paginate(page: params[:page],
                                                                                              per_page: 30)
      when 'user'
        search = User.ransack(params[:q])
        @search_users = search.result(distinct: true).order(created_at: :desc).paginate(page: params[:page],
                                                                                              per_page: 30)
      end
    end
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
end
