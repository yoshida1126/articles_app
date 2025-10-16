class ArticleDraftsController < ApplicationController
  before_action :logged_in_user, only: %i[new commit edit update destroy]
  before_action :correct_user, only: %i[preview commit edit update_draft update destroy]
  before_action :set_remaining_upload_quota, only: %i[new edit]

  def preview
  end

  def new
    @draft = ArticleDraft.new
  end

  def save_draft
    # ユーザーの1日あたりの記事投稿数を制限するサービスを初期化
    limit_service = UserPostLimitService.new(current_user)

    # 1日の投稿数制限を超えていないかチェック
    if limit_service.over_limit?
      flash[:alert] = "1日の記事投稿は#{UserPostLimitService::DAILY_LIMIT}件までです。"
      redirect_to root_path and return
    end

    # 記事作成時の画像処理などを含むサービスを呼び出して、ArticleDraftオブジェクトを生成
    @draft = ArticleImageService.new(current_user, params, :create).process

    if @draft.save
      # 投稿成功時、下書きの数をカウント
      limit_service.track_post

      redirect_to user_path(current_user.id, tab: 'dratfs'), notice: '下書きを保存しました'
    else
      render 'articles/new', status: :unprocessable_entity
    end
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

    authorize_resource_owner(@draft)
  end
end
