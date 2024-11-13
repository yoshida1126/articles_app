class UsersController < ApplicationController
  before_action :logged_in_user, only: %i[show following followers]
  before_action :unconfirmed_account_check, only: [:show]

  def show
    @articles = @user.articles.paginate(page: params[:page], per_page: 15)
  end

  def check
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
