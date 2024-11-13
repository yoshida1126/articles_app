require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  describe '#new' do
    it 'ログインページにアクセスできること' do
      get login_path
      expect(response).to have_http_status :ok
    end
  end

  describe '#create' do
    let(:user) { FactoryBot.create(:user) }

    context 'with valid information' do
      it 'ログインできること' do
        sign_in user
        get "/users/#{user.id}"
        expect(response).to have_http_status :ok
      end
    end
  end

  describe '#destroy' do
    let(:user) { FactoryBot.create(:user) }

    before do
      sign_in user
    end

    it 'ログアウトできること' do
      # ログアウト
      delete logout_path
      get "/users/#{user.id}"
      expect(response).to_not have_http_status :ok
    end
  end
end
