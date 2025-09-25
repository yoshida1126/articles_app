# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  include ImageUtils

  before_action :configure_sign_up_params, only: [:create]
  before_action :authenticate_user!, only: %i[edit update destroy]
  before_action :correct_user, only: %i[edit update destroy]
  before_action :logged_in_user, only: [:destroy]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    super
    return unless params[:user][:profile_img].present?

    resource.profile_img.attach(params[:user][:profile_img])
  end

  # GET /resource/edit
  def edit
    set_remaining_avatar_update_count
  end

  # PUT /resource
  def update
    @user = current_user

    if update_resource(@user, user_params)
      check_avatar_change_limit
      redirect_to root_path, notice: "アカウント情報を更新しました。"
    else
      set_remaining_avatar_update_count
      render 'edit', status: :unprocessable_entity
    end
  end

  # DELETE /resource
  def destroy
    User.find(params[:id]).destroy
    flash[:notice] = 'アカウントを削除しました。'
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

  def user_params
    # devise_parameter_sanitizer.permit(:account_update, keys: %i[name email birthday introduction password password_confirmation profile_img])
    params.require(:user).permit(
      :name,
      :email,
      :birthday,
      :introduction,
      :password,
      :password_confirmation,
      :profile_img
    )
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name profile_img birthday introduction])
  end

  def correct_user
    @user = User.find(params[:id])
    return if @user == current_user

    flash[:alert] = '※他のユーザーのアカウント情報は編集出来ません。'
    redirect_to(root_url, status: :see_other)
  end

  def after_update_path_for(resource)
    user_path(resource)
  end

  def check_avatar_change_limit
    return unless params[:user] && params[:user][:profile_img].present?

    key = "profile_update_count:#{current_user.id}:#{Date.today}"
    seconds_until_end_of_day = (Time.current.in_time_zone("Asia/Tokyo").end_of_day - Time.current).to_i

    if !$redis.exists?(key)
      $redis.set(key, 0)
      $redis.expire(key, seconds_until_end_of_day)
    end

    current_count = $redis.get(key).to_i

    if current_count >= 5
      redirect_to edit_user_registration_path, alert: "プロフィール画像の変更は1日5回までです。"
    else
      $redis.incr(key)
    end
  end

  def set_remaining_avatar_update_count
    key = "profile_update_count:#{current_user.id}:#{Date.today}"
    seconds_until_end_of_day = (Time.current.in_time_zone("Asia/Tokyo").end_of_day - Time.current).to_i

    if !$redis.exists?(key)
      $redis.set(key, 0)
      $redis.expire(key, seconds_until_end_of_day)
    end

    today_count = $redis.get(key).to_i
    @remaining_avatar_update_count = 5 - today_count
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
