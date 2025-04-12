class ArticleImageService
    include ImageUtils
    include ArticleParamsPermitter

    def initialize(user, params, action)
        @user = user
        @params = params
        @action = action
    end

    def process
        case @action
        when :create
            handle_article_images_for_create
        when :update
            handle_article_images_for_update
        else
            raise "Unknown action: #{@action}"
        end
        @article
    end

    private

    def handle_article_images_for_create
        blob_signed_ids = JSON.parse(@params[:article][:blob_signed_ids])

        @article = @user.articles.build(resize_article_header_image(article_params))
        @article.image.attach(article_params[:image]) # ヘッダー画像のアタッチ処理

        image_urls = extract_s3_urls(@params[:article][:content]) # 画像が保存されている場所のURLを取得
        used_blob_signed_ids = get_blob_signed_id_from_url(image_urls) # URLを元に使われている画像のblob_signed_idの配列を取得
        attach_images_to_resource(@article.article_images, used_blob_signed_ids) # 記事本文に使われた画像のアタッチ処理

        unused_blob_signed_ids = blob_signed_ids - used_blob_signed_ids # 使われていない画像のblob_signed_idの配列を取得
        unused_blob_delete(unused_blob_signed_ids) # 使われなかった画像のpurge処理
    end

    def handle_article_images_for_update
        @article = @user.articles.find(@params[:id])
        blob_signed_ids = JSON.parse(@params[:article][:blob_signed_ids])

        attached_signed_ids = @article.article_images.map(&:signed_id)

        image_urls = extract_s3_urls(@params[:article][:content]) # 画像が保存されている場所のURLを取得
        used_blob_signed_ids = get_blob_signed_id_from_url(image_urls) # URLを元に使われている画像のblob_signed_idの配列を取得

        used_attached_signed_ids = attached_signed_ids & used_blob_signed_ids # 編集後にも使われているアタッチ済みの画像を抽出
        attach_images_to_resource(@article.article_images, used_blob_signed_ids - used_attached_signed_ids) # 記事の編集により追加された画像のアタッチ処理

        unused_blob_signed_ids = calculate_unused_blob_signed_ids(
            blob_signed_ids, attached_signed_ids, used_blob_signed_ids
        )
        unused_blob_delete(unused_blob_signed_ids) # 使われなかった画像や、消された画像のpurge処理

        resize_and_attach_article_header_image if article_params[:image].present?
    end
end
