class LikesController < ApplicationController
  before_action :logged_in_user

  def create
    @article = Article.find_by(id: params[:article_id])

    unless @article
      flash[:alert] = "記事が見つかりませんでした。"
      redirect_to root_path and return
    end

    # 「連続いいね」を防止するレート制限サービスを初期化
    limiter = LikeRateLimiterService.new(user: current_user, article: @article)
 
    # 連続での「いいね」操作が許可されているかをチェック
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
        # 最後に「いいね」した時間を記録
        limiter.record_like_time

        # どのいいねボタンを更新するか判定（詳細ページ or 一覧）
        target_class = URI(request.referer.to_s).path == "/articles/#{@article.id}" ? '.likes_btn' : ".likes_btn_#{@article.id}"

        format.turbo_stream do
          render turbo_stream: turbo_stream.update_all(target_class, partial: 'likes/btn', locals: { article: @article })
        end
      else
        flash.now[:alert] = "「いいね」に失敗しました。"
        format.turbo_stream {
          render turbo_stream: turbo_stream.update("flash", partial: "layouts/flash")
        }
      end
    end
  end

  def destroy
    @article = Article.find_by(id: params[:article_id])

    unless @article
      flash[:alert] = "記事が見つかりませんでした。"
      redirect_to root_path and return
    end

    @article_like = Like.find_by(user_id: current_user.id, article_id: params[:article_id])

    unless @article_like
      flash[:alert] = "この記事をいいねしていないか、権限がありません。"
      redirect_to root_path and return
    end

    respond_to do |format|
      if @article_like.destroy
        # どのいいねボタンを更新するか判定（詳細ページ or 一覧）
        target_class = URI(request.referer.to_s).path == "/articles/#{@article.id}" ? '.likes_btn' : ".likes_btn_#{@article.id}"
        format.turbo_stream do
          render turbo_stream: turbo_stream.update_all(target_class, partial: 'likes/btn', locals: { article: @article })
        end
      else
        flash.now[:alert] = "「いいね」の取り消しに失敗しました。"
        format.turbo_stream {
          render turbo_stream: turbo_stream.update("flash", partial: "layouts/flash")
        }
      end
    end
  end
end
