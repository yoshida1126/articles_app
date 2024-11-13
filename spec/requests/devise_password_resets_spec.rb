require 'rails_helper'

RSpec.describe 'PasswordResets', type: :request do
  let(:user) { FactoryBot.create(:user) }
  before do
    ActionMailer::Base.deliveries.clear
  end

  describe '#new' do
    it '正しいフォームが表示されていること' do
      get new_user_password_path
      expect(response.body).to include 'name="user[email]"'
    end
  end

  describe '#create' do
    context 'with a valid email address' do
      it '送信するメールが１件増えること' do
        expect do
          post user_password_path, params: { user: { email: user.email } }
        end.to change(ActionMailer::Base.deliveries, :count).by 1
      end

      it '成功時のflashが表示されること' do
        post user_password_path, params: { user: { email: user.email } }
        expect(flash).to_not be_empty
      end

      it 'ルートパスにリダイレクトされること' do
        post user_password_path, params: { user: { email: user.email } }
        expect(response).to redirect_to new_user_session_url
      end
    end

    context 'with an invalid email address' do
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
