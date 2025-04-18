class ArticleCommentImageService
    include ImageUtils
    include ArticleCommentParams::ArticleCommentParamsPermitter

    def initialize(user, params, action)
        @user = user
        @params = params
        @action = action
        # @blob_finder は、URL または signed_id を元に ActiveStorage::Blob を検索するための Proc です。
        @blob_finder = ->(blob_key) { find_blob_by_blob_key(blob_key) }
    end

    def process
        case @action
        when :create
            handle_article_comment_images_for_create
            @article_comment
        when :update
            handle_article_comment_images_for_update
            return @article_comment, @params
        else
            raise "Unknown action: #{@action}"
        end
    end

    private

    def handle_article_comment_images_for_create
        # article_comment_paramsメソッドにより取り出せなくなる前にblob_signed_idsを取得
        blob_signed_ids = JSON.parse(@params[:article_comment][:blob_signed_ids])

        @article_comment = @user.article_comments.new(sanitized_article_comment_params(@params))
        @article_comment.article = Article.find(@params[:article_id])

        image_urls = extract_s3_urls(@params[:article_comment][:comment])
        used_blob_signed_ids = get_blob_signed_id_from_url(image_urls, blob_finder: @blob_finder)

        attach_images_to_resource(@article_comment.comment_images, used_blob_signed_ids, blob_finder: @blob_finder)

        unused_blob_signed_ids = blob_signed_ids - used_blob_signed_ids # 使われていない画像のsigned_idの配列を取得
        unused_blob_delete(unused_blob_signed_ids, blob_finder: @blob_finder) # 使われなかった画像のpurge処理
    end

    def handle_article_comment_images_for_update
        # article_comment_paramsメソッドにより取り出せなくなる前にblob_signed_idsを取得
        blob_signed_ids = JSON.parse(@params[:article_comment][:blob_signed_ids])

        @article_comment = ArticleComment.find(@params[:id])

        attached_signed_ids = @article_comment.comment_images.map(&:signed_id)
        image_urls = extract_s3_urls(@params[:article_comment][:comment])
        used_blob_signed_ids = get_blob_signed_id_from_url(image_urls, blob_finder: @blob_finder)

        if attached_signed_ids.present?
            # 二重にアタッチしないようにするための処理
            used_attached_signed_ids = attached_signed_ids & used_blob_signed_ids
            new_blob_signed_ids = used_blob_signed_ids - used_attached_signed_ids

            attach_images_to_resource(@article_comment.comment_images, new_blob_signed_ids, blob_finder: @blob_finder)

            combined_blob_signed_ids = blob_signed_ids.concat(attached_signed_ids)
            unused_blob_signed_ids = combined_blob_signed_ids - used_blob_signed_ids
        else
            attach_images_to_resource(@article_comment.comment_images, used_blob_signed_ids, blob_finder: @blob_finder)

            unused_blob_signed_ids = blob_signed_ids - used_blob_signed_ids
        end
        # attachments_finder は、signed_id を元に ActiveStorage::Attachment を検索するための Proc です。
        attachments_finder = ->(blob_id) { find_attachments(blob_id) }
        # 使われなかった画像のpurge処理
        unused_blob_delete(unused_blob_signed_ids, blob_finder: @blob_finder, attachments_finder: attachments_finder)
    end
end