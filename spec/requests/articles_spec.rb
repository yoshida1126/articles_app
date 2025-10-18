require 'rails_helper'

RSpec.describe "Articles", type: :request do

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

  describe "#show" do 

    context "as a logged in user" do 
      before do 
        sign_in user 
      end 

      it "投稿した記事の詳細ページにアクセスできること" do 
        get "/articles/#{article.id}"
        expect(response).to have_http_status(:success)
      end

      it "自分の非公開記事にアクセスできること" do
        get "/articles/#{private_article.id}"
        expect(response).to have_http_status(:success)
      end
    end 

    context "as a logged in user(other_user)" do
      before do
        sign_in other_user
      end

      it "他のユーザーの非公開記事にアクセスできないこと" do
        get "/articles/#{private_article.id}"
        expect(response).to redirect_to root_path
      end
    end

    context "as a non logged in user" do 
      it "投稿されている記事の詳細ページにアクセスできること"do 
        get "/articles/#{article.id}"
        expect(response).to have_http_status(:ok)
      end
    end 
  end

  describe "#destroy" do 
    context "as a logged in user" do 

      before do 
        sign_in user
      end 

      it "記事の削除ができること" do 
        expect {
          delete article_path(article)
        }.to change(Article, :count).by -1
      end 

      it "プロフィールページにリダイレクトされること" do 
        delete article_path(article)
        expect(response).to redirect_to "/users/#{user.id}" 
      end 

      it "flashが表示されること" do 
        delete article_path(article)
        expect(flash).to be_any 
      end 
    end 

    context "as a wrong user" do 
      before do 
        sign_in (other_user) 
      end 

      it "別のユーザーの記事は削除できないこと" do 
        expect {
          delete article_path(article)
        }.to_not change(Article, :count)
      end 
    end 

    context "as a non logged in user" do 
      
      it "記事の削除ができないこと" do 
        expect {
          delete article_path(article)
        }.to_not change(Article, :count)
      end 

      it "ログインページにリダイレクトされること" do 
        delete article_path(article)  
        expect(response).to redirect_to login_url 
      end 
    end 
  end 
end