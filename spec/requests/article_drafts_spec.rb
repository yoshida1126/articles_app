require 'rails_helper'

RSpec.describe "ArticleDrafts", type: :request do
  let!(:user) { FactoryBot.create(:user) } 
  let(:other_user) { FactoryBot.create(:other_user) }
  let!(:article_draft) do
    FactoryBot.create(:article_draft, user: user)
  end

  describe "#preview" do 

    context "as a logged in user" do 
      before do 
        sign_in user 
      end 

      it "下書きのプレビューページにアクセスできること" do 
        get "/users/#{ user.id }/article_drafts/#{ article_draft.id }/preview"
        expect(response).to have_http_status(:success)
      end
    end 

    context "as a logged in user(other_user)" do
      before do
        sign_in other_user
      end

      it "下書き記事のプレビューページにはアクセスできないこと"do 
        get "/users/#{ user.id }/article_drafts/#{ article_draft.id }/preview"
        expect(response).to redirect_to root_path
      end
    end

    context "as a non logged in user" do 
      it "下書き記事のプレビューページにはアクセスできないこと"do 
        get "/users/#{ user.id }/article_drafts/#{ article_draft.id }/preview"
        expect(response).to redirect_to login_path
      end
    end 
  end

  describe "#new" do

    context "as a logged in user" do
      it "記事作成ページにアクセスできること" do
        sign_in user
        get "/users/#{ user.id }/article_drafts/new"
        expect(response).to have_http_status(:success)
      end 
    end

    context "as a logged in user(other user)" do
      it "他のユーザーの記事作成ページにアクセスできないこと" do
        sign_in other_user
        get "/users/#{ user.id }/article_drafts/new"
        expect(response).to redirect_to root_path
      end
    end

    context "as a non logged in user" do
      it "記事作成ページにアクセスできないこと" do
        get "/users/#{ user.id }/article_drafts/new"
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "#save_draft" do 

    context "with valid information(as a logged in user)" do 
      before do
        @valid_draft_params = {
          title: "test",
          content: "test",
          tag_list: "test",
        }
        sign_in user 
        get "/users/#{ user.id }/article_drafts/new"
      end 

      it "下書きの保存に成功すること" do
        expect {
          post save_draft_user_article_drafts_path, params: { user: user, article_draft: @valid_draft_params }
        }.to change(ArticleDraft, :count).by 1
      end 

      it "下書きの保存後、プロフィールページの下書き記事のタブのリンクにリダイレクトされること" do 
        post save_draft_user_article_drafts_path, params: { user: user, article_draft: @valid_draft_params }
        expect(response).to redirect_to drafts_user_path(user)
      end
    end

    context "as a logged in other user" do
      before do
        @valid_draft_params = {
          title: "test",
          content: "test",
          tag_list: "test",
        }
        sign_in other_user
        post save_draft_user_article_drafts_path(user), params: { article_draft: @valid_draft_params }
      end

      it "他のユーザーの下書きは保存できないこと" do
        expect(response).to redirect_to(root_path)
      end
    end
  end 

  describe "#commit" do

    context "with valid information(as a logged in user)" do 
      before do
        @valid_draft_params = {
          title: "test",
          content: "test",
          tag_list: "test",
        }
        sign_in user 
        get "/users/#{ user.id }/article_drafts/new"
      end

      it "公開記事としての投稿に成功すること" do
        expect {
          post commit_user_article_drafts_path(user), params: {
            article_draft: @valid_draft_params,
            article: { published: "true" }
          }
        }.to change(Article, :count).by 1
      end 

      it "公開記事の投稿後、プロフィールページの投稿記事のタブのリンクにリダイレクトされること" do 
        post commit_user_article_drafts_path(user), params: {
          article_draft: @valid_draft_params,
          article: { published: "true" }
        }
        expect(response).to redirect_to user_path(user)
      end
    end

    context "with invalid information(as a logged in user)" do
      
      before do 
        @invalid_draft_params = {
          title: "",
          content: "",
          tag: ""
        }
        sign_in user 
        get "/users/#{ user.id }/article_drafts/new"
      end 

      it "投稿できないこと" do
        expect {
          post commit_user_article_drafts_path(user), params: {
            article_draft: @invalid_draft_params,
            article: { published: "true" }
          }
        }.to_not change(ArticleDraft, :count)
      end 
    end

    context "as a logged in user(other user)" do
      before do
        @valid_draft_params = {
          title: "test",
          content: "test",
          tag_list: "test",
        }
        sign_in other_user 
      end

      it "他のユーザーの記事は投稿できないこと" do
        post commit_user_article_drafts_path(user), params: {
          article_draft: @valid_draft_params,
          article: { published: "true" }
        }
        expect(response).to redirect_to root_path
      end
    end
  end
  
  describe "#edit" do 

    context "as a logged in user" do 
      before do 
        sign_in (user)
        get "/users/#{ user.id }/article_drafts/#{ article_draft.id }/edit"
      end 

      it "下書きの編集ページにアクセスできること" do 
        expect(response).to have_http_status(:success)
      end
    end

    context "as a logged in user(other user)" do
      before do 
        sign_in other_user
        get "/users/#{ user.id }/article_drafts/#{ article_draft.id }/edit"
      end

      it "他のユーザーの下書きの編集ページにはアクセスできないこと" do
        expect(response).to redirect_to root_path
      end
    end

    context "as a non logged in user" do 
      before do 
        get "/users/#{ user.id }/article_drafts/#{ article_draft.id }/edit"
      end

      it "下書きの編集ページにアクセスできないこと" do 
        expect(response).to have_http_status(:see_other)
      end 

      it "ログインページにリダイレクトされること" do 
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "#update_draft" do 

    context "with valid information(as a logged in user)" do 
      before do
        sign_in (user)
        @valid_draft_params = {
          title: "TEST",
          content: "TEST",
          tag_list: "TEST",
        }
        get "/users/#{ user.id }/article_drafts/#{ article_draft.id }/edit"
        patch "/users/#{ user.id }/article_drafts/#{ article_draft.id}/update_draft", params: { user: user, article_draft: @valid_draft_params }
      end

      it "下書きの編集に成功すること" do 
        article_draft.reload 
        expect(article_draft.title).to eq @valid_draft_params[:title]
        expect(article_draft.content).to eq @valid_draft_params[:content]
      end 

      it "下書きの編集後、プロフィールページに下書き記事のタブのリンクにリダイレクトされること" do
        expect(response).to redirect_to drafts_user_path(user)
      end
    end 

    context "as a logged in user(other user)" do
      before do
        @valid_draft_params = {
          title: "TEST",
          content: "TEST",
          tag_list: "TEST",
        }
        sign_in other_user
        patch update_draft_user_article_draft_path(user, article_draft), params: { article_draft: @valid_draft_params }
      end

      it "他のユーザーの下書きは編集できないこと" do
        expect(response).to redirect_to root_path
      end
    end
  end 

  describe "#update" do
    context "with valid information(as a logged in user)" do 
      let!(:article) { FactoryBot.create(:article) }
      let!(:article_draft) do
        FactoryBot.create(:article_draft, article: article, user: user)
      end

      before do
        sign_in (user)
        @valid_draft_params = {
          title: "TEST",
          content: "TEST",
          tag_list: "TEST",
        }
        get edit_user_article_draft_path(user, article_draft)
        patch "/users/#{ user.id }/article_drafts/#{ article_draft.id }", params: { article_draft: @valid_draft_params, article: { published: "true" } }
      end

      it "記事の編集に成功すること" do 
        article.reload 
        expect(article.title).to eq @valid_draft_params[:title]
        expect(article.content).to eq @valid_draft_params[:content]
      end 

      it "記事の編集後、プロフィールページにリダイレクトされること" do
        expect(response).to redirect_to user_path(user)
      end
    end 

    context "as a logged in user(other user)" do
      let!(:article) { FactoryBot.create(:article) }
      let!(:article_draft) do
        FactoryBot.create(:article_draft, article: article, user: user)
      end

      before do
        sign_in other_user
        @valid_draft_params = {
          title: "TEST",
          content: "TEST",
          tag_list: "TEST",
        }
        patch "/users/#{ user.id }/article_drafts/#{ article_draft.id }", params: { article_draft: @valid_draft_params, article: { published: "true" } }
      end

      it "他のユーザーの記事は編集できないこと" do
        expect(response).to redirect_to root_path
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
          delete user_article_draft_path(user, article_draft)
        }.to change(ArticleDraft, :count).by -1
      end 

      it "プロフィールページの下書き記事のタブのリンクにリダイレクトされること" do 
        delete user_article_draft_path(user, article_draft)
        expect(response).to redirect_to drafts_user_path(user)
      end 
    end 

    context "as a wrong user" do 
      before do 
        sign_in other_user
      end 

      it "他のユーザーの下書きは削除できないこと" do 
        expect {
          delete user_article_draft_path(user, article_draft)
        }.to_not change(ArticleDraft, :count)
      end 
    end 

    context "as a non logged in user" do 
      
      it "下書きの削除ができないこと" do 
        expect {
          delete user_article_draft_path(user, article_draft)
        }.to_not change(ArticleDraft, :count)
      end 

      it "ログインページにリダイレクトされること" do 
        delete user_article_draft_path(user, article_draft)
        expect(response).to redirect_to login_url 
      end 
    end 
  end 
end
