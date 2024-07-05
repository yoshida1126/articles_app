class UsersController < ApplicationController
  before_action :logged_in_user, only: [:show]
  before_action :unconfirmed_account_check, only: [:show] 

  def show
  end

  def check 
    @user = current_user 
  end 
  
  private 

  def logged_in_user 
    unless user_signed_in? 
      flash[:alert] = "ログインしてください。" 
      redirect_to login_url, status: :see_other 
    end 
  end 

  def unconfirmed_account_check 
    @user = User.find(params[:id])
    if @user.confirmed_at.nil? 
      redirect_to root_url
    else 
      @user 
    end
  end 
end
