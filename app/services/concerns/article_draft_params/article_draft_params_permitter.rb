module ArticleDraftParams
    module ArticleDraftParamsPermitter
        def sanitized_article_draft_params(params)
            params[:article_draft].delete(:images)
            params[:article_draft].delete(:blob_signed_ids)
            params[:article_draft].delete(:draft_id)

            params.require(:article_draft).permit(:title, :content, :image, :tag_list, article_images: [])
        end
    end
end