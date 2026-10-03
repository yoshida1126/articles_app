require 'rails_helper'

RSpec.describe 'Admin::Statistics', type: :request do

  let(:admin_user) { FactoryBot.create(:admin_user) }

  describe '#users' do
    before do
      sign_in admin_user
    end

    it 'allows access to the user statistics detail page' do
      get '/admin/statistics/users'
      expect(response).to have_http_status(:success)
    end
  end

  describe '#articles' do
    before do
      sign_in admin_user
    end

    it 'allows access to the article statistics detail page' do
      get '/admin/statistics/articles'
      expect(response).to have_http_status(:success)
    end
  end

  describe '#comments' do
    before do
      sign_in admin_user
    end

    it 'allows access to the comment statistics detail page' do
      get '/admin/statistics/comments'
      expect(response).to have_http_status(:success)
    end
  end

  describe '#favorite_article_lists' do
    before do
      sign_in admin_user
    end

    it 'allows access to the favorite article list statistics detail page' do
      get '/admin/statistics/favorite_article_lists'
      expect(response).to have_http_status(:success)
    end
  end

  describe '#tags' do
    before do
      sign_in admin_user
    end

    it 'allows access to the tag statistics detail page' do
      get '/admin/statistics/tags'
      expect(response).to have_http_status(:success)
    end
  end
end
