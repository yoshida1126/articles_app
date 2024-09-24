class LikesController < ApplicationController
  before_action :logged_in_user 
  
  def create
    @article = Article.find_by(id: params[:article_id])
    @article_like = Like.new(user_id: current_user.id, article_id: params[:article_id]) 
    respond_to do |format| 
      unless URI(request.referer.to_s).path == "/articles/#{@article.id}"
        if @article_like.save
          format.turbo_stream do 
            render turbo_stream: turbo_stream.update_all(".likes_btn_#{@article.id}", partial: "likes/btn", locals: { article: @article })
          end 
        end 
      else 
        if @article_like.save
          format.turbo_stream do 
            render turbo_stream: turbo_stream.update_all(".likes_btn", partial: "likes/btn", locals: { article: @article })
          end 
        end 
      end 
    end
  end

  def destroy
    @article = Article.find_by(id: params[:article_id])
    @article_like = Like.find_by(user_id: current_user.id, article_id: params[:article_id]) 
    respond_to do |format| 
      unless URI(request.referer.to_s).path == "/articles/#{@article.id}"
        if @article_like.destroy 
          format.turbo_stream do 
            render turbo_stream: turbo_stream.update_all(".likes_btn_#{@article.id}", partial: "likes/btn", locals: { article: @article })
          end
        end 
      else 
        if @article_like.destroy
          format.turbo_stream do 
            render turbo_stream: turbo_stream.update_all(".likes_btn", partial: "likes/btn", locals: { article: @article })
          end 
        end 
      end 
    end
  end
end
