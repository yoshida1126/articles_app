class ArticleCommentsController < ApplicationController
    before_action :logged_in_user 
    
    def create 
        article = Article.find(params[:article_id]) 
        comment = current_user.article_comments.new(article_comment_params) 
        comment.article_id = article.id
        respond_to do |format|  
          if comment.save 
            @article = Article.find(params[:article_id]) 
            @tags = @article.tag_counts_on(:tags)
            @article_comment = ArticleComment.new 
            format.html { redirect_to @article }
            format.turbo_stream 
          else   
            @article = Article.find(params[:article_id]) 
            @tags = @article.tag_counts_on(:tags)
            @article_comment = ArticleComment.new 
            @error_comment = comment
            format.html { redirect_to @article } 
            format.turbo_stream 
          end  
        end 
    end 

    def destroy 
        @article = Article.find(params[:article_id])
        @article_comment = ArticleComment.find(params[:id])
        if @article_comment.user == current_user 
            respond_to do |format| 
              if @article_comment.destroy 
                format.html { redirect_to @article }
                format.turbo_stream 
              end 
            end 
        end 
    end

    def edit 
        @article_comment = ArticleComment.find(params[:id]) 
    end 

    def update 
        @article_comment = ArticleComment.find(params[:id])
        if @article_comment.user == current_user
          respond_to do |format|  
            if @article_comment.update(article_comment_params) 
              @article = Article.find(params[:article_id]) 
              @tags = @article.tag_counts_on(:tags)
              @article_comment = ArticleComment.new 
              format.html { redirect_to @article }
              format.turbo_stream 
            else   
              @article = Article.find(params[:article_id]) 
              @error_comment = @article_comment 
              format.html { redirect_to @article_comment, @error_comment } 
              format.turbo_stream 
            end  
          end 
        end
    end 

    private 

    def article_comment_params 
        params.require(:article_comment).permit(:comment) 
    end 
end
