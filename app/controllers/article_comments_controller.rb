class ArticleCommentsController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user, only: %i[edit update destroy]
  before_action :set_upload_quota_data, only: %i[create update]

  def create
    prepare_article_comment_data(:create) # 部分更新後に使われるデータの用意

    article_comment = params[:article_comment][:comment]

    # サービスクラスで画像に関する処理をする
    @article_comment = ArticleCommentImageService.new(current_user, params, :create).process

    respond_to do |format|
      if @article_comment.save
        # 画像をアタッチするとupdated_atが更新されてしまうため、ビュー側で編集済みと表示させないための処理
        @article_comment.update(updated_at: @article_comment.created_at)
        format.turbo_stream
      else
        @error_comment = @article_comment
        format.turbo_stream
      end
    end
  end

  def edit
    @article_comment = ArticleComment.find(params[:id])
  end

  def update
    article_comment = params[:article_comment][:comment]

    # サービスクラスで画像に関する処理をする
    service = ArticleCommentImageService.new(current_user, params, :update)
    @article_comment, @params = service.process

    prepare_article_comment_data(:update) # 部分更新後に使われるデータの用意

    respond_to do |format|
      if @article_comment.update(service.sanitized_article_comment_params(@params))
        format.turbo_stream
      else
        @error_comment = @article_comment
        format.turbo_stream
      end
    end
  end

  def destroy
    @article = Article.find(params[:article_id])
    @article_comment = ArticleComment.find(params[:id])

    respond_to do |format|
      if @article_comment.destroy
        format.turbo_stream
      end
    end
  end

  private

  def correct_user
    @article_comment = ArticleComment.find(params[:id])

    return if current_user.admin

    authorize_resource_owner(@article_comment)
  end

  def prepare_article_comment_data(action)
    @article = Article.find(params[:article_id])
    @tags = @article.tag_counts_on(:tags)
    @comment = ArticleComment.new if action === :create
  end
end
