class ArticleCommentLikesController < ApplicationController
  before_action :logged_in_user
  before_action :set_resources
  before_action :check_consecutive_like, only: :create

  def create
    @like = ArticleCommentLike.new(user: current_user, article_comment: @article_comment)

    respond_to do |format|
      if @like.save
        @rate_limiter.record_like_time
        format.turbo_stream do
          render turbo_stream: turbo_stream.update_all(".likes_btn_#{@article_comment.id}",
                                                       partial: 'article_comment_likes/btn',
                                                       locals: { article: @article,
                                                                 article_comment: @article_comment })
        end
      end
    end
  end

  def destroy
    @like = ArticleCommentLike.find_by(user: current_user, article_comment: @article_comment)
    unless @like
      flash[:alert] = "このコメントをいいねしていないか、権限がありません。"
      return redirect_to root_path
    end

    respond_to do |format|
      if @like.destroy
        format.turbo_stream do
          render turbo_stream: turbo_stream.update_all(".likes_btn_#{@article_comment.id}",
                                                       partial: 'article_comment_likes/btn',
                                                       locals: { article: @article,
                                                                 article_comment: @article_comment })
        end
      end
    end
  end

  private

  def set_resources
    @article = Article.find_by(id: params[:article_id])
    @article_comment = ArticleComment.find_by(id: params[:article_comment_id])
  end

  def check_consecutive_like
    @rate_limiter = ArticleCommentLikeRateLimiter.new(user: current_user, article_comment: @article_comment)
    unless @rate_limiter.allowed?
      flash.now[:alert] = "連続で「いいね」はできません。あと#{@rate_limiter.remaining_time}秒待ってください。"
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.update("flash", partial: "layouts/flash")
        }
      end
      return false
    end
  end
end
