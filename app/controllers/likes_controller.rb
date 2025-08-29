class LikesController < ApplicationController
  before_action :logged_in_user

  def create
    key = "user:#{current_user.id}:like:#{params[:article_id]}"
    last_liked = $redis.get(key)

    if last_liked.present?
      remaining = 3 - (Time.now.to_i - last_liked.to_i)
      if remaining > 0
        flash.now[:alert] = "連続で「いいね」はできません。あと#{remaining}秒待ってください。"

        respond_to do |format|
          format.turbo_stream {
            render turbo_stream: turbo_stream.update("flash", partial: "layouts/flash")
          }
        end
        return
      end
    end

    # 記事に対していいねをつける
    @article = Article.find_by(id: params[:article_id])
    @article_like = Like.new(user_id: current_user.id, article_id: params[:article_id])
    respond_to do |format|
      if URI(request.referer.to_s).path == "/articles/#{@article.id}"
        if @article_like.save
          $redis.set(key, Time.now.to_i, ex: 3)
          format.turbo_stream do
            render turbo_stream: turbo_stream.update_all('.likes_btn', partial: 'likes/btn',
                                                                       locals: { article: @article })
          end
        end
      elsif @article_like.save
        $redis.set(key, Time.now.to_i, ex: 3)
        format.turbo_stream do
          render turbo_stream: turbo_stream.update_all(".likes_btn_#{@article.id}", partial: 'likes/btn',
                                                                                    locals: { article: @article })
        end
      end
    end
  end

  def destroy
    # 記事のいいねを取り消す
    @article = Article.find_by(id: params[:article_id])
    @article_like = Like.find_by(user_id: current_user.id, article_id: params[:article_id])
    respond_to do |format|
      if URI(request.referer.to_s).path == "/articles/#{@article.id}"
        if @article_like.destroy
          format.turbo_stream do
            render turbo_stream: turbo_stream.update_all('.likes_btn', partial: 'likes/btn',
                                                                       locals: { article: @article })
          end
        end
      elsif @article_like.destroy
        format.turbo_stream do
          render turbo_stream: turbo_stream.update_all(".likes_btn_#{@article.id}", partial: 'likes/btn',
                                                                                    locals: { article: @article })
        end
      end
    end
  end
end
