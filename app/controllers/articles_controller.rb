class ArticlesController < ApplicationController
  before_action :logged_in_user, only: %i[destroy]
  before_action :correct_user, only: %i[destroy]
  before_action :set_remaining_upload_quota, only: %i[show]

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

  def edit
    @user = current_user
    @article = @user.articles.find(params[:id])

    remaining = HeaderImageRateLimiterService::MAX_UPDATES_PER_DAY - HeaderImageRateLimiterService.count_for_today(current_user.id)
    @header_image_change_remaining = remaining > 0 ? remaining : 0
  end

  def update
    service = ArticleImageService.new(current_user, params, :update)
    @article, @params = service.process

    if HeaderImageRateLimiterService.exceeded?(current_user.id, @params[:article][:image])
      redirect_to root_path, alert: "ヘッダー画像の変更は1日#{HeaderImageRateLimiterService::MAX_UPDATES_PER_DAY}回までです。" and return
    end

    if @article.update(service.sanitized_article_params(@params))
      # 本日のヘッダー画像変更回数をインクリメント
      HeaderImageRateLimiterService.increment(current_user.id) if @params[:article][:image].present?

      redirect_to user_path(@article.user, tab: 'published'), notice: '記事を編集しました'
    else
      render 'articles/edit', status: :unprocessable_entity
    end
  end

  def destroy
    @article.destroy
    flash[:notice] = '記事を削除しました。'
    redirect_to current_user, status: :see_other
  end

  private

  def correct_user
    # 記事の作成者が、現在ログイン中のユーザー、または管理者かを確認
    @article = Article.find(params[:id])

    return if current_user.admin
    
    authorize_resource_owner(@article)
  end
end
