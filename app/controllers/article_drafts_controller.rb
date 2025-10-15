class ArticleDraftsController < ApplicationController
  before_action :logged_in_user, only: %i[new commit edit update destroy]
  before_action :correct_user, only: %i[preview save_draft commit edit update_draft update destroy]
  before_action :set_remaining_upload_quota, only: %i[new edit]

  def preview
  end

  def new
    @draft = ArticleDraft.new
  end

  def save_draft
  end

  def commit
  end

  def edit
  end

  def update_draft
  end

  def update
  end

  def destroy
    @draft.destroy
    redirect_to user_path(current_user.id, tab: 'drafts'), notice: '下書きを削除しました'
  end

  private

  def correct_user
    # 記事の作成者が、現在ログイン中のユーザーかを確認
    @draft = ArticleDraft.find(params[:id])
    
    authorize_resource_owner(@article)
  end
end
