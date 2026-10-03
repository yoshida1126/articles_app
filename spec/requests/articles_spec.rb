require 'rails_helper'

RSpec.describe 'Articles', type: :request do

  let(:user) { FactoryBot.create(:user) } 
  let(:other_user) { FactoryBot.create(:other_user) }

  let(:article) { Article.create(title: "test", content: "test", tag_list: "test", user_id: user.id) }
  let!(:article_draft) do
    FactoryBot.create(:article_draft, article: article)
  end

  let(:private_article) { Article.create(
      title: "test",
      content: "test",
      tag_list: "test",
      published: false,
      user_id: user.id,
      article_draft: article_draft) 
  }

  describe '#show' do 

    context 'when logged in as the owner' do 
      before do 
        sign_in user 
      end 

      it 'allows access to the published article detail page' do 
        get "/articles/#{article.id}"
        expect(response).to have_http_status(:success)
      end

      it "allows access to the user's private article" do
        get "/articles/#{private_article.id}"
        expect(response).to have_http_status(:success)
      end
    end 

    context 'when logged in as another user' do
      before do
        sign_in other_user
      end

      it "does not allow access to another user's private article" do
        get "/articles/#{private_article.id}"
        expect(response).to redirect_to root_path
      end
    end

    context 'when not logged in' do 
      it 'allows access to the published article detail page' do 
        get "/articles/#{article.id}"
        expect(response).to have_http_status(:ok)
      end
    end 
  end

  describe '#destroy' do 
    context 'when logged in as the owner' do 

      before do 
        sign_in user
      end 

      it 'allows the article to be deleted' do 
        expect {
          delete article_path(article)
        }.to change(Article, :count).by -1
      end 

      it 'redirects to the profile page after deleting the article' do 
        delete article_path(article)
        expect(response).to redirect_to "/users/#{user.id}" 
      end 

      it 'displays a flash message' do 
        delete article_path(article)
        expect(flash).to be_any 
      end 
    end 

    context 'when logged in as another user' do 
      before do 
        sign_in (other_user) 
      end 

      it "does not allow another user's article to be deleted" do 
        expect {
          delete article_path(article)
        }.to_not change(Article, :count)
      end 
    end 

    context 'when not logged in' do 
      
      it 'does not allow the article to be deleted' do 
        expect {
          delete article_path(article)
        }.to_not change(Article, :count)
      end 

      it 'redirects to the login page' do 
        delete article_path(article)  
        expect(response).to redirect_to login_url 
      end 
    end 
  end 
end