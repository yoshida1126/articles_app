class ArticlesController < ApplicationController
  before_action :logged_in_user, only: %i[destroy]
  before_action :correct_user, only: %i[destroy]
  before_action :set_upload_quota_data, only: %i[show]

  def index; end

  def show
    @article = Article.find(params[:id])

    if !@article.published? && @article.user != current_user
      redirect_to root_path, alert: "指定された記事は存在しません。"
    end

    @tags = @article.tag_counts_on(:tags)
    @comment = ArticleComment.new

    return unless current_user

    # 以下はログイン時のみ必要な情報

    @favorite_article_lists = current_user.favorite_article_lists
    @favorite = Favorite.new
  end

  def destroy
    @article.destroy
    flash[:notice] = '記事を削除しました。'
    redirect_to current_user, status: :see_other
  end
end

private

def correct_user
  # 記事の作成者が、現在ログイン中のユーザー、または管理者かを確認
  @article = Article.find(params[:id])

  return if current_user.admin
    
  authorize_resource_owner(@article)
end