require 'rails_helper'

RSpec.describe "Admin::Statistics", type: :request do

  let(:admin_user) { FactoryBot.create(:admin_user) }

  describe '#users' do
    before do
      sign_in admin_user
    end

    it 'ユーザーの統計詳細ページにアクセスできること' do
      get '/admin/statistics/users'
      expect(response).to have_http_status(:success)
    end
  end

  describe '#articles' do
    before do
      sign_in admin_user
    end

    it '記事の統計詳細ページにアクセスできること' do
      get '/admin/statistics/articles'
      expect(response).to have_http_status(:success)
    end
  end

  describe '#comments' do
    before do
      sign_in admin_user
    end

    it 'コメントの統計詳細ページにアクセスできること' do
      get '/admin/statistics/comments'
      expect(response).to have_http_status(:success)
    end
  end

  describe '#favorite_article_lists' do
    before do
      sign_in admin_user
    end

    it 'お気に入りリストの統計詳細ページにアクセスできること' do
      get '/admin/statistics/favorite_article_lists'
      expect(response).to have_http_status(:success)
    end
  end

  describe '#tags' do
    before do
      sign_in admin_user
    end

    it 'タグの統計詳細ページにアクセスできること' do
      get '/admin/statistics/tags'
      expect(response).to have_http_status(:success)
    end
  end
end
