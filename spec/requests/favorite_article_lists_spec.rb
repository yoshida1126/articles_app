require 'rails_helper'

RSpec.describe "FavoriteArticleLists", type: :request do

    let(:user) { FactoryBot.create(:user, :with_favorite_article_lists) }
    let!(:favorite_article_list) { user.favorite_article_lists.first }
    let!(:article) { Article.create(title: "test", content: "test", tag_list: "test", user_id: user.id) }

    describe "#index" do
        before do 
            sign_in user 
        end 

        it "リストの一覧ページにアクセスできること" do
            get user_favorite_article_lists_path(user)
            expect(response).to have_http_status(:success)
        end
    end

    describe "#show" do
        before do
            sign_in user
        end

        it "お気に入りリストのページにアクセスできること" do
            get "/users/#{ user.id }/favorite_article_lists/#{ favorite_article_list.id }"
            expect(response).to have_http_status(:success)
        end
    end

    describe "#new" do
        before do
            sign_in user
        end

        it "リストの作成ページにアクセスできること" do 
            get "/users/#{ user.id }/favorite_article_lists/new"
            expect(response).to have_http_status(:success)
        end
    end

    describe "#create" do
        before do 
            @valid_favorite_list_params = { 
                list_title: "test"
            }
            sign_in user 
            get "/users/#{ user.id }/favorite_article_lists/new"
        end 

        it "リストの作成に成功すること" do
            expect {
                post user_favorite_article_lists_path, params: { favorite_article_list: @valid_favorite_list_params }
            }.to change(FavoriteArticleList, :count).by 1
        end 
    end

    describe "#edit" do
        before do
            sign_in user
            get "/users/#{ user.id }/favorite_article_lists/#{ favorite_article_list.id }/edit"
        end

        it "リストの編集ページにアクセスできること" do
            expect(response).to have_http_status(:success)
        end
    end

    describe "#update" do
        before do
            @valid_favorite_list_params = { 
                list_title: "test test"
            }
            sign_in user
            get "/users/#{ user.id }/favorite_article_lists/#{ favorite_article_list.id }/edit"
        end

        it "リストを編集できること" do
            patch user_favorite_article_list_path, params: { favorite_article_list: @valid_favorite_list_params }
            favorite_article_list.reload 
            expect(favorite_article_list.list_title).to eq @valid_favorite_list_params[:list_title]
        end
    end

    describe "#destroy" do
        before do
            sign_in user
            get "/users/#{ user.id }/favorite_article_lists/#{ favorite_article_list.id }/edit"
        end

        it "リストの削除ができること" do 
            expect {
                delete user_favorite_article_list_path(favorite_article_list)
            }.to change(FavoriteArticleList, :count).by -1
        end 
    end
end