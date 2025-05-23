class ArticleImageService
    include ImageUtils
    include ArticleParams::ArticleParamsPermitter

    def initialize(user, params, action)
        @user = user
        @params = params
        @action = action
        # @blob_finder は、URL または signed_id を元に ActiveStorage::Blob を検索するための Proc です。
        @blob_finder = ->(blob_key) { find_blob_by_blob_key(blob_key) }
        @image_resizer = ->(tempfile) { resize_image(tempfile) }
    end

    def process
        case @action
        when :create
            handle_article_images_for_create
            # create時は@paramsが不要なため、articleのみ返す
            @article
        when :update
            handle_article_images_for_update
            # update時は後続処理でparamsも使うため、両方返す
            return @article, @params
        else
            raise "Unknown action: #{@action}"
        end
    end

    private

    def handle_article_images_for_create
        blob_signed_ids = JSON.parse(@params[:article][:blob_signed_ids])
        @params[:article][:image] = resize_article_header_image(@params[:article][:image])

        @sanitized_params = sanitized_article_params(@params)
        @article = @user.articles.build(@sanitized_params)

        # 画像が保存されている場所のURLを取得
        image_urls = extract_s3_urls(@sanitized_params[:content])
        # URLを元に使われている画像のblob_signed_idの配列を取得
        used_blob_signed_ids = get_blob_signed_id_from_url(image_urls, blob_finder: @blob_finder)
        # 記事本文に使われた画像のアタッチ処理
        attach_images_to_resource(@article.article_images, used_blob_signed_ids, blob_finder: @blob_finder)
        # 使われていない画像のblob_signed_idの配列を取得
        unused_blob_signed_ids = blob_signed_ids - used_blob_signed_ids
        # 使われなかった画像のpurge処理
        unused_blob_delete(unused_blob_signed_ids, blob_finder: @blob_finder)
    end

    def handle_article_images_for_update
        blob_signed_ids = JSON.parse(@params[:article][:blob_signed_ids])
        @article = @user.articles.find(@params[:id])

        # ヘッダー画像が設定されている場合のみ、リサイズ処理を行う
        # 記事更新時にヘッダー画像が消えてしまうことを防ぐため、nil が入らないようにサービスクラス側でも確認しています。
        if @params[:article][:image].present?
            @params[:article][:image] = resize_article_header_image(@params[:article][:image])
        end

        attached_signed_ids = @article.article_images.map(&:signed_id)

        # 画像が保存されている場所のURLを取得
        image_urls = extract_s3_urls(@params[:article][:content])
        # URLを元に使われている画像のblob_signed_idの配列を取得
        used_blob_signed_ids = get_blob_signed_id_from_url(image_urls, blob_finder: @blob_finder)
        # 編集後にも使われているアタッチ済みの画像を抽出
        used_attached_signed_ids = attached_signed_ids & used_blob_signed_ids
        # 記事の編集により追加された画像のアタッチ処理
        attach_images_to_resource(@article.article_images, used_blob_signed_ids - used_attached_signed_ids, blob_finder: @blob_finder)

        # 使われなかった画像や、消された画像の抽出処理
        unused_blob_signed_ids = calculate_unused_blob_signed_ids(
            blob_signed_ids, attached_signed_ids, used_blob_signed_ids
        )
        # attachments_finder は、signed_id を元に ActiveStorage::Attachment を検索するための Proc です。
        attachments_finder = ->(blob_id) { find_attachments(blob_id) }
        # 使われなかった画像や、消された画像のpurge処理
        unused_blob_delete(unused_blob_signed_ids, blob_finder: @blob_finder, attachments_finder: attachments_finder)
    end
end
