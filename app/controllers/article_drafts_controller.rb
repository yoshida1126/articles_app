class ArticleDraftsController < ApplicationController
  before_action :logged_in_user, only: %i[preview new commit edit update destroy]
  before_action :authorize_user!, only: %i[new save_draft commit]
  before_action :correct_user, only: %i[preview edit update_draft update destroy]
  before_action :set_remaining_upload_quota, only: %i[new edit]

  def preview; end

  def new
    @draft = ArticleDraft.new
  end

  def save_draft

    # 画像処理などを含むサービスを呼び出して、ArticleDraftオブジェクトを生成
    @draft = ArticleImageService.new(current_user, params, :save_draft).process

    @draft.user = current_user
    @draft.editing = true

    if @draft.save
      redirect_to drafts_user_path(current_user), notice: '下書きを保存しました'
    else
      @remaining_mb = UploadQuotaService.new(user: current_user, type: :article).remaining_mb
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
    @article, @draft = ArticleImageService.new(current_user, params, :commit).process

    ActiveRecord::Base.transaction do
      @draft.save!
      @article.save!
      limit_service.track_post
    end

    if @article.published == false
      redirect_to private_articles_user_path(current_user), notice: '非公開記事として投稿しました'
    else
      redirect_to current_user, notice: '新しい記事を投稿しました'
    end

  rescue ActiveRecord::RecordInvalid
    @remaining_mb = UploadQuotaService.new(user: current_user, type: :article).remaining_mb
    render 'article_drafts/new', status: :unprocessable_entity
  end

  def edit
    @user = current_user

    @article = @draft&.article

    remaining = HeaderImageRateLimiterService::MAX_UPDATES_PER_DAY - HeaderImageRateLimiterService.count_for_today(current_user.id)
    @header_image_change_remaining = remaining > 0 ? remaining : 0
  end

  def update_draft
    if HeaderImageRateLimiterService.exceeded?(current_user.id, params[:article_draft][:image])
      redirect_to root_path, alert: "ヘッダー画像の変更は1日#{HeaderImageRateLimiterService::MAX_UPDATES_PER_DAY}回までです。" and return
    end

    service = ArticleImageService.new(current_user, params, :update_draft)
    @draft, @params = service.process

    @draft = DraftArticleSyncService.new(draft: @draft, action: :update_draft).call

    if @draft.update(service.sanitized_article_draft_params(@params))
      # 本日のヘッダー画像変更回数をインクリメント
      HeaderImageRateLimiterService.increment(current_user.id) if @params[:article_draft][:image].present?

      redirect_to drafts_user_path(current_user), notice: '下書きを編集しました'
    else
      remaining = HeaderImageRateLimiterService::MAX_UPDATES_PER_DAY - HeaderImageRateLimiterService.count_for_today(current_user.id)
      @header_image_change_remaining = remaining > 0 ? remaining : 0

      @remaining_mb = UploadQuotaService.new(user: current_user, type: :article).remaining_mb

      render 'article_drafts/edit', status: :unprocessable_entity
    end
  end

  def update
    if HeaderImageRateLimiterService.exceeded?(current_user.id, params[:article_draft][:image])
      redirect_to root_path, alert: "ヘッダー画像の変更は1日#{HeaderImageRateLimiterService::MAX_UPDATES_PER_DAY}回までです。" and return
    end

    @article, @draft, notice_or_errors, status = DraftArticleSyncService.new(draft: @draft, action: :update, user: current_user, params: params).call

    if status == :failure
      remaining = HeaderImageRateLimiterService::MAX_UPDATES_PER_DAY - HeaderImageRateLimiterService.count_for_today(current_user.id)
      @header_image_change_remaining = remaining > 0 ? remaining : 0
      @remaining_mb = UploadQuotaService.new(user: current_user, type: :article).remaining_mb
      render 'article_drafts/edit', status: :unprocessable_entity
    else
      path = @article.published ? current_user : private_articles_user_path(current_user)
      redirect_to path, notice: notice_or_errors
    end
  end

  def destroy
    DraftArticleSyncService.new(draft: @draft, action: :destroy).call

    redirect_to drafts_user_path(current_user), notice: '下書きを削除しました'
  end

  private

  def correct_user
    @draft = current_user.article_drafts.find_by(id: params[:id])
    unless @draft
      redirect_to root_path, alert: "不正なアクセスです" and return
    end
    authorize_resource_owner(@draft)
  end
end
