module ArticleParams
    module ArticleParamsPermitter
        def sanitized_article_params(params)
            params[:article_draft].delete(:images)
            params[:article_draft].delete(:blob_signed_ids)

            article_params = params.require(:article).permit(:published)
            draft_params   = params.require(:article_draft).permit(:title, :content, :image, :tag_list, article_images: [])

            draft_params.merge(article_params)
        end
    end
end
