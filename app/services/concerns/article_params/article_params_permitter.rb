module ArticleParams
    module ArticleParamsPermitter
        def sanitized_article_params(params)
            params[:article].delete(:images)
            params[:article].delete(:blob_signed_ids)

            params.require(:article).permit(:published, :title, :content, :image, :tag_list, article_images: [])
        end
    end
end