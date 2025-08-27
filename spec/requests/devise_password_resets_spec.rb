require 'rails_helper'

RSpec.describe 'PasswordResets', type: :request do
  let(:user) { FactoryBot.create(:user) }

  describe '#new' do
    it '正しいフォームが表示されていること' do
      get new_user_password_path
      expect(response.body).to include 'name="user[email]"'
    end
  end

  describe '#create' do
    xcontext 'with a valid email address' do
      it '成功時のflashが表示されること' do
        post user_password_path, params: { user: { email: user.email } }
        expect(flash).to_not be_empty
      end

      it 'ログイン画面にリダイレクトされること' do
        post user_password_path, params: { user: { email: user.email } }
        expect(response).to redirect_to new_user_session_url
      end
    end

    xcontext 'with an invalid email address' do
      it 'エラーメッセージが表示されること' do
        post user_password_path, params: { user: { email: '' } }
        expect(response.body).to include 'alert-danger'
      end

      it '同じページが表示されること' do
        post user_password_path, params: { user: { email: '' } }
        expect(response.body).to include 'パスワード再設定'
      end
    end
  end
end