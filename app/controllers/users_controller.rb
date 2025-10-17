class UsersController < ApplicationController
  before_action :logged_in_user, only: %i[show following followers]
  before_action :unconfirmed_account_check, only: [:show, :private_articles, :drafts]

  def show
    @articles = @user.articles.published.paginate(page: params[:page], per_page: 15)
    @private_articles = @user.articles.unpublished.paginate(page: params[:page], per_page: 15)
    @articles_count = @articles.count

    limit_service = UserPostLimitService.new(current_user)
    @count = UserPostLimitService::DAILY_LIMIT - limit_service.current_count
    @tab = :published
    render :show
  end

  def private_articles
    @articles = @user.articles.published.paginate(page: params[:page], per_page: 15)
    @articles_count = @articles.count

    limit_service = UserPostLimitService.new(current_user)
    @count = UserPostLimitService::DAILY_LIMIT - limit_service.current_count

    @private_articles = @user.articles.unpublished.paginate(page: params[:page], per_page: 15)
    @tab = :private
    render :show
  end

  def drafts
    @articles = @user.articles.published.paginate(page: params[:page], per_page: 15)
    @articles_count = @articles.count

    limit_service = UserPostLimitService.new(current_user)
    @count = UserPostLimitService::DAILY_LIMIT - limit_service.current_count

    @drafts = @user.article_drafts.editing.paginate(page: params[:page], per_page: 15)

    @tab = :drafts
    render :show
  end

  def account_delete_confirmation
    @user = current_user
  end

  def following
    @title = 'フォローしているユーザー'
    @user = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page], per_page: 15)
    @articles = @user.articles
    render 'show_follow'
  end

  def followers
    @title = 'フォロワー'
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page], per_page: 15)
    @articles = @user.articles
    render 'show_follow'
  end

  private

  def unconfirmed_account_check
    @user = User.find(params[:id])
    if @user.confirmed_at.nil?
      redirect_to root_url
    else
      @user
    end
  end
end
