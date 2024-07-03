class UsersController < ApplicationController
  before_action :logged_in_user, only: [:show]

  def show
    @user = User.find(params[:id]) 
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
end
