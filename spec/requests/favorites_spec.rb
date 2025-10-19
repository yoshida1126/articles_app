require 'rails_helper'

RSpec.describe "FavoriteArticleLists", type: :request do

    let(:user) { FactoryBot.create(:user, :with_favorite_article_lists) }
    let!(:favorite_article_list) { user.favorite_article_lists.first }
    let!(:article) { Article.create(title: "test", content: "test", tag_list: "test", user_id: user.id) }
    let!(:article_draft) { FactoryBot.create(:article_draft, article: article, user: user) }

     describe "#create" do
        before do 
            sign_in user
        end 

        it "リストに記事を追加できること" do
            expect do
                post favorites_path, params: { favorite: { article_id: article.id, favorite_article_list_id: favorite_article_list.id } },
                xhr: true, headers: { Accept: 'text/vnd.turbo-stream.html' }
            end.to change(Favorite, :count).by 1
        end 
    end

    describe "#destroy" do
        before do
            sign_in user
            post favorites_path, params: { favorite: { article_id: article.id, favorite_article_list_id: favorite_article_list.id } },
            xhr: true, headers: { Accept: 'text/vnd.turbo-stream.html' }
        end

        it "リストに登録した記事を消せること" do 
            @favorite = Favorite.find_by(article: article, favorite_article_list: favorite_article_list)
            expect do
                delete favorite_path(@favorite), params: { favorite: { article_id: article.id, favorite_article_list_id: favorite_article_list.id } },
                xhr: true, headers: { Accept: 'text/vnd.turbo-stream.html' }
            end.to change(Favorite, :count).by(-1)
        end
    end
end