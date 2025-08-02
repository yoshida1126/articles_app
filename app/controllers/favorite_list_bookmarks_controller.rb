class FavoriteListBookmarksController < ApplicationController
  before_action :logged_in_user, only: %i[create destroy]

  def create
    @favorite_list_bookmark = FavoriteListBookmark.new

    respond_to do |format|
      @favorite_article_list = FavoriteArticleList.find(params.dig(:favorite_list_bookmark, :favorite_article_list_id))
      @user = @favorite_article_list.user
      current_user.bookmark(@favorite_article_list)
      format.html { redirect_to user_favorite_article_lists_path(@user) }
      format.turbo_stream do
        render turbo_stream: turbo_stream.update_all(".bookmark-#{@favorite_article_list.id}", partial: 'favorite_list_bookmarks/bookmark',
                                                                  locals: { list: @favorite_article_list })
        flash.now[:notice] = "#{@user.name}さんのリストを保存しました。"
      end
    end
  end

  def destroy
    @favorite_article_list = FavoriteArticleList.find(params.dig(:favorite_list_bookmark, :favorite_article_list_id))
    @favorite_list_bookmark = FavoriteListBookmark.find_by(user_id: current_user.id, favorite_article_list_id: params.dig(:favorite_list_bookmark, :favorite_article_list_id))
    @user = @favorite_article_list.user
    current_user.unbookmark(@favorite_list_bookmark)
    respond_to do |format|
      format.html { redirect_to user_favorite_article_lists_path(@user) }
      format.turbo_stream do 
        render turbo_stream: turbo_stream.update_all(".bookmark-#{@favorite_article_list.id}", partial: 'favorite_list_bookmarks/bookmark',
                                                                  locals: { list: @favorite_article_list })
        flash.now[:notice] = 'ブックマークをはずしました。'                                                         
      end
    end
  end
end
