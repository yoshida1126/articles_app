class ApplicationController < ActionController::Base
  include ApplicationHelper
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :search

  def home; end

  def search
    @search = Article.ransack(params[:q])
    return unless params[:q].present?

    @search_word = @search.conditions.first.values.first.value

    if /\A#.+/ =~ @search_word
      @search_word = @search_word.sub(/^#/, '')
      @search_word.gsub!(" ", "")
      @search_word.gsub!("　", "")
      redirect_to tag_path(@search_word)
    else
      @search_articles = @search.result(distinct: true).order(created_at: :desc).paginate(page: params[:page],
                                                                                        per_page: 32)
    end
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
