class LikesController < ApplicationController
  before_action :logged_in_user

  def create
    @article = Article.find_by(id: params[:article_id])
    limiter = LikeRateLimiterService.new(user_id: current_user.id, article_id: @article.id)

    unless limiter.allowed?
      flash.now[:alert] = "連続で「いいね」はできません。あと#{limiter.remaining_time}秒待ってください。"
      return respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.update("flash", partial: "layouts/flash")
        }
      end
    end

    @article_like = Like.new(user_id: current_user.id, article_id: params[:article_id])

    respond_to do |format|
      if @article_like.save
        limiter.record_like_time
        target_class = URI(request.referer.to_s).path == "/articles/#{@article.id}" ? '.likes_btn' : ".likes_btn_#{@article.id}"
        format.turbo_stream do
          render turbo_stream: turbo_stream.update_all(target_class, partial: 'likes/btn', locals: { article: @article })
        end
      end
    end
  end

  def destroy
    # 記事のいいねを取り消す
    @article = Article.find_by(id: params[:article_id])
    @article_like = Like.find_by(user_id: current_user.id, article_id: params[:article_id])

    unless @article_like
      flash[:alert] = "この記事をいいねしていないか、権限がありません。"
      redirect_to root_path and return
    end

    respond_to do |format|
      if @article_like.destroy
        target_class = URI(request.referer.to_s).path == "/articles/#{@article.id}" ? '.likes_btn' : ".likes_btn_#{@article.id}"
        format.turbo_stream do
          render turbo_stream: turbo_stream.update_all(target_class, partial: 'likes/btn', locals: { article: @article })
        end
      end
    end
  end
end
