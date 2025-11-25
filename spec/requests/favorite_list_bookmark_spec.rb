require 'rails_helper'

RSpec.describe "FavoriteArticleLists", type: :request do

    let(:user) { FactoryBot.create(:user) }
    let!(:other_user) { FactoryBot.create(:other_user, :with_favorite_article_lists) }
    let!(:favorite_article_list) { other_user.favorite_article_lists.first }

     describe "#create" do
        before do 
            sign_in user
        end 

        it "リストをブックマークできること" do
            expect do
                post favorite_list_bookmarks_path, params: { favorite_article_list_id: favorite_article_list.id },
                xhr: true, headers: { Accept: 'text/vnd.turbo-stream.html' }
            end.to change(FavoriteListBookmark, :count).by 1
        end 
    end

    describe "#destroy" do
        before do
            sign_in user
            post favorite_list_bookmarks_path, params: { favorite_article_list_id: favorite_article_list.id },
            xhr: true, headers: { Accept: 'text/vnd.turbo-stream.html' }
        end

        it "リストのブックマークを解除できること" do 
            @favorite_list_bookmark = FavoriteListBookmark.find_by(user: user, favorite_article_list: favorite_article_list)
            expect do
                delete favorite_list_bookmark_path(@favorite_list_bookmark), params: { favorite_list_bookmark: { favorite_article_list_id: favorite_article_list.id } },
                xhr: true, headers: { Accept: 'text/vnd.turbo-stream.html' }
            end.to change(FavoriteListBookmark, :count).by(-1)
        end
    end
end