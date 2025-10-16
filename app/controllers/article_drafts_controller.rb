class ArticleDraftsController < ApplicationController
  before_action :logged_in_user, only: %i[new commit edit update destroy]
  before_action :correct_user, only: %i[preview edit update_draft update destroy]
  before_action :set_remaining_upload_quota, only: %i[new edit]

  def preview
  end

  def new
    @draft = ArticleDraft.new
  end

  def save_draft
    # 画像処理などを含むサービスを呼び出して、ArticleDraftオブジェクトを生成
    @draft = ArticleImageService.new(current_user, params, :save_draft).process

    if @draft.save
      redirect_to drafts_user_path(current_user), notice: '下書きを保存しました'
    else
      render 'article_drafts/new', status: :unprocessable_entity
    end
  end

  def commit
    # ユーザーの1日あたりの記事投稿数を制限するサービスを初期化
    limit_service = UserPostLimitService.new(current_user)

    # 1日の投稿数制限を超えていないかチェック
    if limit_service.over_limit?
      flash[:alert] = "1日の記事投稿は#{UserPostLimitService::DAILY_LIMIT}件までです。"
      redirect_to root_path and return
    end

    # 画像処理などを含むサービスを呼び出して、Articleオブジェクトを生成
    @article = ArticleImageService.new(current_user, params, :commit).process

    if @article.save
      # 記事投稿成功時、下書きの数をカウント
      limit_service.track_post

      if @article.published == false
        redirect_to private_articles_user_path(current_user), notice: '未公開記事として投稿しました'
      else
        redirect_to current_user, notice: '新しい記事を投稿しました'
      end
    else
      render 'article_drafts/new', status: :unprocessable_entity
    end
  end

  def edit
  end

  def update_draft
  end

  def update
  end

  def destroy
    @draft.destroy
    redirect_to drafts_user_path(current_user), notice: '下書きを削除しました'
  end

  private

  def correct_user
    @draft = ArticleDraft.find_by(id: params[:id])

    if @draft
      authorize_resource_owner(@draft)
      return
    end

    @article = Article.find(params[:id])
    authorize_resource_owner(@article)

    @draft = @article.article_draft || @article.build_article_draft
  end
end
