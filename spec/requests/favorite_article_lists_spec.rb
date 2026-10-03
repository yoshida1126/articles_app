require 'rails_helper'

RSpec.describe 'FavoriteArticleLists', type: :request do

    let(:user) { FactoryBot.create(:user, :with_favorite_article_lists) }
    let!(:favorite_article_list) { user.favorite_article_lists.first }
    let!(:article) { Article.create(title: "test", content: "test", tag_list: "test", user_id: user.id) }

    describe '#index' do
        before do 
            sign_in user 
        end 

        it 'allows access to the favorite article lists page' do
            get user_favorite_article_lists_path(user)
            expect(response).to have_http_status(:success)
        end
    end

    describe '#show' do
        before do
            sign_in user
        end

        it 'allows access to the favorite article list page' do
            get "/users/#{ user.id }/favorite_article_lists/#{ favorite_article_list.id }"
            expect(response).to have_http_status(:success)
        end
    end

    describe '#new' do
        before do
            sign_in user
        end

        it 'allows access to the favorite article list creation page' do 
            get "/users/#{ user.id }/favorite_article_lists/new"
            expect(response).to have_http_status(:success)
        end
    end

    describe '#create' do
        before do 
            @valid_favorite_list_params = { 
                list_title: "test"
            }
            sign_in user 
            get "/users/#{ user.id }/favorite_article_lists/new"
        end 

        it 'successfully creates a favorite article list' do
            expect {
                post user_favorite_article_lists_path, params: { favorite_article_list: @valid_favorite_list_params }
            }.to change(FavoriteArticleList, :count).by 1
        end 
    end

    describe '#edit' do
        before do
            sign_in user
            get "/users/#{ user.id }/favorite_article_lists/#{ favorite_article_list.id }/edit"
        end

        it 'allows access to the favorite article list edit page' do
            expect(response).to have_http_status(:success)
        end
    end

    describe '#update' do
        before do
            @valid_favorite_list_params = { 
                list_title: "test test"
            }
            sign_in user
            get "/users/#{ user.id }/favorite_article_lists/#{ favorite_article_list.id }/edit"
        end

        it 'allows the favorite article list to be updated' do
            patch user_favorite_article_list_path, params: { favorite_article_list: @valid_favorite_list_params }
            favorite_article_list.reload 
            expect(favorite_article_list.list_title).to eq @valid_favorite_list_params[:list_title]
        end
    end

    describe '#destroy' do
        before do
            sign_in user
            get "/users/#{ user.id }/favorite_article_lists/#{ favorite_article_list.id }/edit"
        end

        it 'allows the favorite article list to be deleted' do 
            expect {
                delete user_favorite_article_list_path(favorite_article_list)
            }.to change(FavoriteArticleList, :count).by -1
        end 
    end
end