class ArticleCommentsController < ApplicationController
  before_action :logged_in_user

  def create
    prepare_article_comment_data(:create) # 部分更新後に使われるデータの用意

    article_comment = params[:article_comment][:comment]

    # サービスクラスで画像に関する処理をする
    @article_comment = ArticleCommentImageService.new(current_user, params, :create).process

    respond_to do |format|
      if @article_comment.save
        # 画像をアタッチするとupdated_atが更新されてしまうため、ビュー側で編集済みと表示させないための処理
        @article_comment.update(updated_at: @article_comment.created_at)
        format.html { redirect_to @article, @tags }
      else
        @error_comment = @article_comment
        format.html { redirect_to @article, @tags, @error_comment }
      end
      format.turbo_stream
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
    return unless @article_comment.user == current_user

    prepare_article_comment_data(:update) # 部分更新後に使われるデータの用意

    respond_to do |format|
      if @article_comment.update(service.sanitized_article_comment_params(@params))
        format.html { redirect_to @article }
      else
        @error_comment = @article_comment
        format.html { redirect_to @article_comment, @error_comment }
      end
      format.turbo_stream
    end
  end

  def destroy
    @article = Article.find(params[:article_id])
    @article_comment = ArticleComment.find(params[:id])
    return unless @article_comment.user == current_user

    respond_to do |format|
      if @article_comment.destroy
        format.html { redirect_to @article }
        format.turbo_stream
      end
    end
  end

  private

  def prepare_article_comment_data(action)
    @article = Article.find(params[:article_id])
    @tags = @article.tag_counts_on(:tags)
    @comment = ArticleComment.new if action == :create
  end

  def increment_comment_image_usage(user, bytes)
    key = "comment_image_usage:#{user.id}:#{Date.today}"
    $redis.incrby(key, bytes)
    $redis.expire(key, 24.hour.to_i) unless $redis.ttl(key) > 0
  end
end
