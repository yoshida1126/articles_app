class ArticleCommentLikesController < ApplicationController
  before_action :logged_in_user
  before_action :set_resources
  before_action :check_consecutive_like, only: :create

  def create
    respond_to do |format|
      if @like.save
        @rate_limiter.record_like_time
        format.turbo_stream do
          render turbo_stream: turbo_stream.update_all(".likes_btn_#{@article_comment.id}",
                                                       partial: 'article_comment_likes/btn',
                                                       locals: { article_comment: @article_comment })
        end
      end
    end
  end

  def destroy
    unless @like
      flash[:alert] = "このコメントをいいねしていないか、権限がありません。"
      return redirect_to root_path
    end

    respond_to do |format|
      if @like.destroy
        @article_comment.reload
        
        format.turbo_stream do
          render turbo_stream: turbo_stream.update_all(".likes_btn_#{@article_comment.id}",
                                                       partial: 'article_comment_likes/btn',
                                                       locals: { article_comment: @article_comment })
        end
      end
    end
  end

  private

  def set_resources
    if action_name == 'create'
      @article_comment = ArticleComment.find_by(id: params[:article_comment_id])
      @like = ArticleCommentLike.new(user: current_user, article_comment: @article_comment)
    elsif action_name == 'destroy'
      @article_comment = ArticleComment.find_by(id: params[:id])
      @like = ArticleCommentLike.find_by(user_id: current_user.id, article_comment_id: params[:id])
    end
  end

  def check_consecutive_like
    @rate_limiter = ArticleCommentLikeRateLimiterService.new(user: current_user, article_comment: @article_comment)
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
