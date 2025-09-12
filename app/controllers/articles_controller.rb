class ArticlesController < ApplicationController
  before_action :logged_in_user, only: %i[new create edit update destroy]
  before_action :correct_user, only: %i[edit update destroy]
  before_action :set_remaining_upload_quota, only: %i[new edit show]

  def index; end

  def show
    @article = Article.find(params[:id])
    @tags = @article.tag_counts_on(:tags)
    @comment = ArticleComment.new

    return unless current_user

    # 以下はログイン時のみ必要な情報

    @favorite_article_lists = current_user.favorite_article_lists
    @favorite = Favorite.new
  end

  def new
    @article = Article.new
  end

  def create
    # ユーザーの1日あたりの記事投稿数を制限するサービスを初期化
    limit_service = UserPostLimitService.new(current_user)

    # 1日の投稿数制限を超えていないかチェック
    if limit_service.over_limit?
      flash[:alert] = "1日の記事投稿は#{UserPostLimitService::DAILY_LIMIT}件までです。"
      redirect_to root_path and return
    end

    # 記事作成時の画像処理などを含むサービスを呼び出して、Articleオブジェクトを生成
    @article = ArticleImageService.new(current_user, params, :create).process

    if @article.save
      # 投稿成功時、投稿数をカウント
      limit_service.track_post

      flash[:notice] = '記事を作成しました。'
      redirect_to current_user
    else
      render 'articles/new', status: :unprocessable_entity
    end
  end

  def edit
    @user = current_user
    @article = @user.articles.find(params[:id])
  end

  def update
    service = ArticleImageService.new(current_user, params, :update)
    @article, @params = service.process

    if @article.update(service.sanitized_article_params(@params))
      flash[:notice] = '記事を編集しました。'
      redirect_to current_user, status: :see_other
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
    # 記事の作成者が、現在ログイン中のユーザーであるかを確認
    @article = Article.find(params[:id])
    authorize_resource_owner(@article)
  end

  def set_remaining_upload_quota
    return unless current_user

    type = action_name == 'show' ? :comment : :article
    @remaining_mb = UploadQuotaService.new(user: current_user, type: type).remaining_mb
  end
end
