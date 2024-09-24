class ArticleCommentLikesController < ApplicationController
    before_action :logged_in_user 

    def create 
        article = Article.find_by(id: params[:article_id])
        article_comment = ArticleComment.find_by(id: params[:article_comment_id])
        like = ArticleCommentLike.new(user_id: current_user.id, article_comment_id: params[:article_comment_id])
        respond_to do |format| 
          if like.save
            format.turbo_stream do 
              render turbo_stream: turbo_stream.update_all(".likes_btn_#{article_comment.id}", partial: "article_comment_likes/btn", locals: { article: article, article_comment: article_comment })
            end 
          end 
        end
    end 

    def destroy 
        article = Article.find_by(id: params[:article_id])
        article_comment = ArticleComment.find_by(id: params[:article_comment_id]) 
        like = ArticleCommentLike.find_by(user_id: current_user.id, article_comment_id: params[:article_comment_id])  
        respond_to do |format|
          if like.destroy 
            format.turbo_stream do 
              render turbo_stream: turbo_stream.update_all(".likes_btn_#{article_comment.id}", partial: "article_comment_likes/btn", locals: { article: article, article_comment: article_comment })
            end 
          end 
        end 
    end 
end
