require 'rails_helper'

RSpec.describe 'ArticleDrafts', type: :request do
  let!(:user) { FactoryBot.create(:user) } 
  let(:other_user) { FactoryBot.create(:other_user) }
  let!(:article_draft) do
    FactoryBot.create(:article_draft, user: user)
  end

  describe '#preview' do 

    context 'when logged in as the owner' do 
      before do 
        sign_in user 
      end 

      it 'allows access to the draft preview page' do 
        get "/users/#{ user.id }/article_drafts/#{ article_draft.id }/preview"
        expect(response).to have_http_status(:success)
      end
    end 

    context 'when logged in as another user' do
      before do
        sign_in other_user
      end

      it 'does not allow access to the draft preview page' do 
        get "/users/#{ user.id }/article_drafts/#{ article_draft.id }/preview"
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when not logged in' do 
      it 'does not allow access to the draft preview page' do 
        get "/users/#{ user.id }/article_drafts/#{ article_draft.id }/preview"
        expect(response).to redirect_to login_path
      end
    end 
  end

  describe '#new' do

    context 'when logged in as the owner' do
      before do
        sign_in user
        get "/users/#{ user.id }/article_drafts/new"
      end

      it 'allows access to the article creation page' do
        expect(response).to have_http_status(:success)
      end

      it 'assigns the draft and an empty versions array' do
        expect(assigns(:draft)).to be_present
        expect(assigns(:versions)).to eq([])
      end
    end

    context 'when logged in as another user'  do
      it "does not allow access to another user's article creation page" do
        sign_in other_user
        get "/users/#{ user.id }/article_drafts/new"
        expect(response).to redirect_to root_path
      end
    end

    context 'when not logged in' do
      it 'does not allow access to the article creation page' do
        get "/users/#{ user.id }/article_drafts/new"
        expect(response).to redirect_to login_path
      end
    end
  end

  describe '#save_draft' do

    context 'with valid information when logged in as the owner' do

      context 'when creating a new draft without draft_id' do
        before do
          @valid_draft_params = {
            title: "test",
            content: "test",
            tag_list: "test",
          }
          sign_in user
          get "/users/#{ user.id }/article_drafts/new"
        end

        subject do 
          post save_draft_user_article_drafts_path,
          params: { 
            user: user,
            article_draft: @valid_draft_params
          } 
        end

        it 'successfully saves the draft' do
          expect { subject }.to change(ArticleDraft, :count).by 1
        end

        it 'redirects to the drafts tab on the profile page after saving the draft' do 
          subject
          expect(response).to redirect_to drafts_user_path(user)
        end
      end

      context 'when saving an existing draft with draft_id' do
        before do
          @valid_draft_params = {
            title: "test",
            content: "test",
            tag_list: "test",
            draft_id: article_draft.id
          }
          article_draft.paper_trail.save_with_version
          sign_in user
          get "/users/#{ user.id }/article_drafts/new"
        end

        subject do
          post save_draft_user_article_drafts_path,
          params: {
            user: user,
            article_draft: @valid_draft_params
          }
        end

        it 'has no version history after saving the draft' do
          expect(article_draft.versions).not_to be_empty
          subject
          expect(article_draft.reload.versions).to be_empty
        end
      end
    end

    context 'when logged in as another user' do
      before do
        @valid_draft_params = {
          title: "test",
          content: "test",
          tag_list: "test",
        }
        sign_in other_user
        post save_draft_user_article_drafts_path(user), params: { article_draft: @valid_draft_params }
      end

      it "does not allow saving another user's draft" do
        expect(response).to redirect_to(root_path)
      end
    end
  end 

  describe '#commit' do

    context 'with valid information when logged in as the owner' do

      context 'when creating a new draft without draft_id' do
        before do
          @valid_draft_params = {
            title: "test",
            content: "test",
            tag_list: "test",
          }
          sign_in user
          get "/users/#{ user.id }/article_drafts/new"
        end

        it 'successfully publishes the article' do
          expect {
            post commit_user_article_drafts_path(user), params: {
              article_draft: @valid_draft_params,
              article: { published: "true" }
            }
          }.to change(Article, :count).by 1
        end 

        it 'redirects to the articles tab on the profile page after publishing the article' do 
          post commit_user_article_drafts_path(user), params: {
            article_draft: @valid_draft_params,
            article: { published: "true" }
          }
          expect(response).to redirect_to user_path(user)
        end
      end

      context 'when saving an existing draft with draft_id' do
        before do
          @valid_draft_params = {
            title: "test",
            content: "test",
            tag_list: "test",
            draft_id: article_draft.id
          }
          article_draft.paper_trail.save_with_version
          sign_in user
          get "/users/#{ user.id }/article_drafts/new"
        end

        subject do
          post commit_user_article_drafts_path(user),
          params: {
            article_draft: @valid_draft_params,
            article: { published: "true" }
          }
        end

        it 'has no version history after saving the draft' do
          expect(article_draft.versions).not_to be_empty
          subject
          expect(article_draft.reload.versions).to be_empty
        end
      end
    end

    context 'with invalid information when logged in as the owner' do
      
      before do 
        @invalid_draft_params = {
          title: "",
          content: "",
          tag: ""
        }
        sign_in user 
        get "/users/#{ user.id }/article_drafts/new"
      end 

      it 'does not allow the article to be published' do
        expect {
          post commit_user_article_drafts_path(user), params: {
            article_draft: @invalid_draft_params,
            article: { published: "true" }
          }
        }.to_not change(ArticleDraft, :count)
      end 
    end

    context 'when logged in as another user' do
      before do
        @valid_draft_params = {
          title: "test",
          content: "test",
          tag_list: "test",
        }
        sign_in other_user 
      end

      it "does not allow publishing another user's article" do
        post commit_user_article_drafts_path(user), params: {
          article_draft: @valid_draft_params,
          article: { published: "true" }
        }
        expect(response).to redirect_to root_path
      end
    end
  end
  
  describe '#edit' do

    let!(:article) do
      Article.create(
        title: "test",
        content: "test",
        tag_list: "test",
        user_id: user.id,
        article_draft: article_draft
      )
    end

    context 'when logged in as the owner' do
      context 'when the draft has no associated article' do
        before do
          sign_in (user)
          article_draft.paper_trail.save_with_version
          get "/users/#{ user.id }/article_drafts/#{ article_draft.id }/edit"
        end

        it 'allows access to the draft edit page' do
          expect(response).to have_http_status(:success)
        end

        it 'assigns the article and a versions array' do
          expect(assigns(:article)).to be_present
          expect(assigns(:versions)).to be_present
        end
      end

      context 'when the draft has an associated article' do
        before do
          sign_in (user)
          article_draft.paper_trail.save_with_version
          get "/users/#{ user.id }/article_drafts/#{ article.article_draft.id }/edit"
        end

        it 'assigns the article and a versions array' do
          expect(assigns(:article)).to be_present
          expect(assigns(:versions)).to be_present
        end
      end
    end

    context 'when logged in as another user' do
      before do
        sign_in other_user
        get "/users/#{ user.id }/article_drafts/#{ article_draft.id }/edit"
      end

      it "does not allow access to another user's draft edit page" do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when not logged in' do
      before do
        get "/users/#{ user.id }/article_drafts/#{ article_draft.id }/edit"
      end

      it 'does not allow access to the draft edit page' do
        expect(response).to have_http_status(:see_other)
      end

      it 'redirects to the login page' do
        expect(response).to redirect_to login_path
      end
    end
  end

  describe '#update_draft' do 

    context 'with valid information when logged in as the owner' do 
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

      it 'successfully updates the draft' do 
        article_draft.reload 
        expect(article_draft.title).to eq @valid_draft_params[:title]
        expect(article_draft.content).to eq @valid_draft_params[:content]
      end 

      it 'redirects to the drafts tab on the profile page after updating the draft' do
        expect(response).to redirect_to drafts_user_path(user)
      end
    end 

    context 'when logged in as another user' do
      before do
        @valid_draft_params = {
          title: "TEST",
          content: "TEST",
          tag_list: "TEST",
        }
        sign_in other_user
        patch update_draft_user_article_draft_path(user, article_draft), params: { article_draft: @valid_draft_params }
      end

      it "does not allow updating another user's draft" do
        expect(response).to redirect_to root_path
      end
    end
  end 

  describe '#update' do
    context 'with valid information when logged in as the owner' do 
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

      it 'successfully updates the article' do 
        article.reload 
        expect(article.title).to eq @valid_draft_params[:title]
        expect(article.content).to eq @valid_draft_params[:content]
      end 

      it 'redirects to the profile page after updating the article' do
        expect(response).to redirect_to user_path(user)
      end
    end 

    context 'when logged in as another user' do
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

      it "does not allow updating another user's article" do
        expect(response).to redirect_to root_path
      end
    end
  end

  describe '#destroy' do 
    context 'when logged in as the owner' do 

      before do 
        sign_in user
      end 

      it 'allows the draft to be deleted' do 
        expect {
          delete user_article_draft_path(user, article_draft)
        }.to change(ArticleDraft, :count).by -1
      end 

      it 'redirects to the drafts tab on the profile page after deleting the draft' do 
        delete user_article_draft_path(user, article_draft)
        expect(response).to redirect_to drafts_user_path(user)
      end 
    end 

    context 'when logged in as another user' do 
      before do 
        sign_in other_user
      end 

      it "does not allow another user's draft to be deleted" do 
        expect {
          delete user_article_draft_path(user, article_draft)
        }.to_not change(ArticleDraft, :count)
      end 
    end 

    context 'when not logged in' do 
      
      it 'does not allow the draft to be deleted' do 
        expect {
          delete user_article_draft_path(user, article_draft)
        }.to_not change(ArticleDraft, :count)
      end 

      it 'redirects to the login page' do 
        delete user_article_draft_path(user, article_draft)
        expect(response).to redirect_to login_url 
      end 
    end 
  end 
end
