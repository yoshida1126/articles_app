module ArticleCommentParams
    module ArticleCommentParamsPermitter
        def sanitized_article_comment_params(params)
            params[:article_comment].delete(:images)
            params[:article_comment].delete(:blob_signed_ids)
    
            params.require(:article_comment).permit(:comment, :created_at, :updated_at, comment_images: [])
        end
    end
end