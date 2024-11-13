class CustomAuthenticationFailure < Devise::FailureApp
  protected

  def redirect_url
    login_url
  end
end
