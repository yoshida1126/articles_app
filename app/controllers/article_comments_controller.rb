class ArticleCommentsController < ApplicationController
  before_action :logged_in_user

  def create
    key = "user:#{current_user.id}:daily_comment_post:#{params[:article_id]}"
    count = $redis.get(key).to_i

    prepare_article_comment_data(:create) # 部分更新後に使われるデータの用意

    if count >= 5
      flash.now[:alert] = "１つの記事につき、１日５回までしかコメントはできません。"
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.update("flash", partial: "layouts/flash")
        }
      end
      return
    end

    # サービスクラスで画像に関する処理をする
    @article_comment = ArticleCommentImageService.new(current_user, params, :create).process

    respond_to do |format|
      if @article_comment.save
        $redis.incr(key)
        $redis.expire(key, 24.hours.to_i) unless $redis.ttl(key) > 0
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
end
