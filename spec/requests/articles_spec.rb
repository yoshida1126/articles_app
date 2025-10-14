require 'rails_helper'

RSpec.describe "Articles", type: :request do

  let(:user) { FactoryBot.create(:user) } 
  let(:other_user) { FactoryBot.create(:other_user) }
  let!(:article) { Article.create(draft: false, title: "test", content: "test", tag_list: "test", user_id: user.id) }

  describe "#show" do 

    context "as a logged in user" do 
      before do 
        sign_in user 
      end 

      it "記事のページにアクセスできること" do 
        get "/articles/#{article.id}"
        expect(response).to have_http_status(:success)
      end 
    end 

    context "as a non logged in user" do 
      it "記事のページにアクセスできること"do 
        get "/articles/#{article.id}"
        expect(response).to have_http_status(:ok)
      end
    end 
  end 

  describe "#new" do

    context "as a logged in user" do
      it "記事作成ページにアクセスできること" do
        sign_in user
        get "/articles/new"
        expect(response).to have_http_status(:success)
      end 
    end

    context "as a non logged in user" do 
      before do 
        get "/articles/new" 
      end 

      it "記事作成ページにアクセスできないこと" do 
        expect(response).to have_http_status(:see_other)
      end 

      it "flashが表示されること" do 
        expect(flash).to be_any
      end 

      it "ログインページにリダイレクトされること" do 
        expect(response).to redirect_to login_path 
      end 
    end 
  end

  describe "#create" do 

    context "with valid information(as a logged in user)" do 
      before do 
        @valid_article_params = {
          draft: false,
          title: "test",
          content: "test",
          tag_list: "test"
        }
        sign_in user 
        get "/articles/new"
      end 

      it "記事の作成に成功すること" do
        expect {
          post articles_path, params: { article: @valid_article_params }
        }.to change(Article, :count).by 1
      end 

      it "記事の投稿後プロフィールページの投稿記事のタブをクリックした状態でリダイレクトされること" do 
        post articles_path, params: { article: @valid_article_params }
        expect(response).to redirect_to "/users/#{user.id}?tab=published" 
      end 
    end 

    context "with invalid information(as a logged in user)" do
      
      before do 
        @invalid_article_params = {
          draft: false,
          title: "",
          content: "",
          tag: ""
        }
        sign_in user 
        get "/articles/new"
      end 

      it "投稿できないこと" do
        expect {
          post articles_path, params: { article: @invalid_article_params }
        }.to_not change(Article, :count)
      end 
    end  
  end 
  
  describe "#edit" do 

    context "as a logged in user" do 
      before do 
        sign_in (user)
        get "/articles/#{article.id}/edit"
      end 

      it "記事の編集ページにアクセスできること" do 
        expect(response).to have_http_status(:success)
      end 
    end 

    context "as a non logged in user" do 
      before do 
        get "/articles/#{article.id}/edit"
      end 

      it "記事の編集ページにアクセスできないこと" do 
        expect(response).to have_http_status(:see_other)
      end 

      it "ログインページにリダイレクトされること" do 
        expect(response).to redirect_to login_path 
      end 

      it "flashが表示されること" do 
        expect(flash).to be_any 
      end 
    end 
  end 

  describe "#update" do 

    context "with valid information(as a logged in user)" do 
      before do 
        sign_in (user)
        @valid_article_params = { 
          draft: false,
          title: "test test", 
          content: "test test",
          tag: "test"
        }
        get "/articles/#{article.id}/edit"
      end 

      it "記事の編集に成功すること" do 
        patch "/articles/#{article.id}", params: { article: @valid_article_params }
        article.reload 
        expect(article.title).to eq @valid_article_params[:title]
        expect(article.content).to eq @valid_article_params[:content]
      end 

      it "記事の編集後プロフィールページの投稿記事のタブをクリックした状態でリダイレクトされること" do 
        patch "/articles/#{article.id}", params: { article: @valid_article_params }
        expect(response).to redirect_to "/users/#{user.id}?tab=published" 
      end
      
      it "成功時のフラッシュメッセージが表示されること" do 
        patch "/articles/#{article.id}", params: { article: @valid_article_params }
        expect(flash).to be_any 
      end 
    end 

    context "with invalid information(as a logged in user)" do 
      before do 
        sign_in (user)
        @invalid_article_params = {
          draft: false,
          title: "", 
          content: "",
          tag: ""
        }
        get "/articles/#{article.id}/edit"
      end 

      it "記事の編集に失敗すること" do 
        patch "/articles/#{article.id}", params: { article: @invalid_article_params }
        article.reload 
        expect(article.title).to_not eq @invalid_article_params[:title]
        expect(article.content).to_not eq @invalid_article_params[:content]
      end
    end 

    context "as a non logged in user" do 
      before do 
        @valid_article_params = {
          draft: false,
          title: "test test", 
          content: "test test",
          tag: "test"
        }
        patch "/articles/#{article.id}", params: { article: @valid_article_params }
      end 

      it "記事の編集ができないこと" do
        article.reload 
        expect(article.title).to_not eq @valid_article_params[:title]
        expect(article.content).to_not eq @valid_article_params[:content]
      end 

      it "ログインページにリダイレクトされること" do 
        expect(response).to redirect_to login_path 
      end 

      it "flashが表示されること" do 
        expect(flash).to be_any 
      end 
    end 

    context "as a wrong user" do 
      before do 
        sign_in other_user
        @valid_article_params = { 
          draft: false,
          title: "test test", 
          content: "test test " 
        }
        patch "/articles/#{article.id}", params: { article: @valid_article_params }
      end 

      it "記事の編集ができないこと" do
        article.reload 
        expect(article.title).to_not eq @valid_article_params[:title]
        expect(article.content).to_not eq @valid_article_params[:content]
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