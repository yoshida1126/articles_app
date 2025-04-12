module ArticleParamsPermitter
    def article_params
        @params[:article].delete(:images)
        @params[:article].delete(:blob_signed_ids)

        @params.require(:article).permit(:title, :content, :image, :tag_list, article_images: [])
    end
end