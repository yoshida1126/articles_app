class ArticleDraftsController < ApplicationController
  before_action :logged_in_user, only: %i[preview new autosave_draft save_draft commit edit update_draft update destroy]
  before_action :authorize_user!, only: %i[new save_draft autosave_draft commit update_draft update]
  before_action :correct_user, only: %i[preview autosave_draft edit update_draft update destroy]
  before_action :set_upload_quota_data, only: %i[new edit]

  def preview
    @tags = @draft.tag_counts_on(:tags)
  end

  def new
    @draft = ArticleDraft.new
  end

  def autosave_draft
    @draft, remaining_mb, max_size = DraftArticleSyncService.new(draft: @draft, action: :autosave_draft, user: current_user, params: params).call

    @draft.save(validate: false)
    render json: {
      status: 'ok',
      id: @draft.id,
      remaining_mb: remaining_mb,
      max_size: max_size,
      updated_at: "#{@draft.updated_at.strftime("%Y-%m-%d %H:%M:%S")}"
    }
  end

  def save_draft
    @draft = DraftArticleSyncService.new(draft: @draft, action: :save_draft, user: current_user, params: params).call

    @draft.save!(validate: false)
    redirect_to drafts_user_path(current_user), notice: '下書きを保存しました'
  end

  def commit
    @article, @draft, notice_or_errors, status = DraftArticleSyncService.new(draft: @draft, action: :commit, user: current_user, params: params).call

    if status == :failure
      set_upload_quota_data
      render 'article_drafts/new', status: :unprocessable_entity
    else
      path = @article.published ? current_user : private_articles_user_path(current_user)
      redirect_to path, notice: notice_or_errors
    end
  end

  def edit
    @user = current_user

    @article = @draft&.article
  end

  def update_draft
    @draft = DraftArticleSyncService.new(draft: @draft, action: :update_draft, user: current_user, params: params).call

    if @draft.save(validate: false)
      redirect_to drafts_user_path(current_user), notice: '下書きを編集しました'
    else
      @remaining_mb = UploadQuotaService.new(user: current_user).remaining_mb

      render 'article_drafts/edit', status: :unprocessable_entity
    end
  end

  def update
    @article, @draft, notice_or_errors, status = DraftArticleSyncService.new(draft: @draft, action: :update, user: current_user, params: params).call

    if status == :failure
      set_upload_quota_data
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
    return unless params[:id].present?

    @draft = current_user.article_drafts.find_by(id: params[:id])
    unless @draft
      redirect_to root_path, alert: "不正なアクセスです" and return
    end
    authorize_resource_owner(@draft)
  end
end
