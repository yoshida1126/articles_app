class FavoritesController < ApplicationController
  before_action :logged_in_user
  # before_action :correct_user, only: :destroy

  def create
    # 記事をお気に入りリストに追加する
    @article = Article.find(params.dig(:favorite, :article_id))
    @favorite_article_lists = current_user.favorite_article_lists
    @favorite = Favorite.new

    respond_to do |format|
      if params.dig(:favorite, :favorite_article_list_id) == ''
        format.html { redirect_to @favorite, @article, @favorite_article_lists, alert: 'リストを選択してください。' }
        format.turbo_stream { flash.now[:alert] = 'リストを選択してください。' }
      else
        @favorite_article_list = FavoriteArticleList.find(params.dig(:favorite, :favorite_article_list_id))
        @favorite_article_list.favorite(@article)
        format.html { redirect_to @favorite, @article, @favorite_article_lists }
        format.turbo_stream do
          flash.now[:notice] = "この記事をお気に入りリスト #{@favorite_article_list.list_title} に追加しました。"
        end
      end
    end
  end

  def destroy
    # 記事をお気に入りリストから消去する
    @favorite_article_list = current_user.favorite_article_lists.find_by(id: params.dig(:favorite,
                                                                                        :favorite_article_list_id))
    @article = Article.find(params.dig(:favorite, :article_id))
    @favorite = Favorite.find(params[:id])
    @favorite_article_list.unfavorite(@favorite)

    @favorites = @favorite_article_list.favorites

    flash.now[:notice] = 'お気に入り記事のリストを整理しました。'

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update(
            "tagged-articles",
            partial: "favorite_article_lists/edit_favorite_articles",
            collection: @favorites,
            as: :favorite
          ),
          turbo_stream.update(
            "flash",
            partial: "layouts/flash"
          )
        ]
      end
    end
  end
end
