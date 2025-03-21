class WelcomeMailer < ApplicationMailer
  def send_when_signup(email)
    mail to: email, subject: '登録完了のお知らせ'
  end
end
