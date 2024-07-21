# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  before_action :configure_permitted_parameters, only: [:update]
  before_action :authenticate_user!, only: [:edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update, :destroy] 
  before_action :logged_in_user, only: [:destroy]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    super
    if params[:profile_img].present?
      resource.profile_img.attach(params[:profile_img])
    end 
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  def update
    super
    if params[:profile_img].present?
      resource.profile_img.attach(params[:profile_img])
    end 
  end

  # DELETE /resource
  def destroy
    User.find(params[:id]).destroy 
    flash[:notice] = "アカウントを削除しました。" 
    redirect_to root_path, status: :see_other 
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  def update_resource(resource, params) 
    if params[:password].present? && params[:password_confirmation].present? 
      resource.update(params) 
    else
      resource.update_without_current_password(params) 
    end
  end 

  def configure_permitted_parameters 
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :profile_img]) 
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :profile_img])
  end

  def correct_user 
    @user = User.find(params[:id]) 
    unless @user == current_user 
      flash[:alert] = "※他のユーザーのアカウント情報は編集出来ません。" 
      redirect_to(root_url, status: :see_other)
    end 
  end 

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource) 
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
