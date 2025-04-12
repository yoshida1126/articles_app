class ArticleCommentImageService
    include ImageUtils
    include ArticleCommentParamsPermitter

    def initialize(user, params, action)
        @user = user
        @params = params
        @action = action
    end

    def process
        case @action
        when :create
            handle_article_comment_images_for_create
        when :update
            handle_article_comment_images_for_update
        else
            raise "Unknown action: #{@action}"
        end
        @article_comment
    end

    private

    def handle_article_comment_images_for_create
        # article_comment_paramsメソッドにより取り出せなくなる前にblob_signed_idsを取得
        blob_signed_ids = JSON.parse(@params[:article_comment][:blob_signed_ids])

        @article_comment = @user.article_comments.new(article_comment_params)
        @article_comment.article = Article.find(@params[:article_id])

        image_urls = extract_s3_urls(@params[:article_comment][:comment])
        used_blob_signed_ids = get_blob_signed_id_from_url(image_urls)

        attach_images_to_resource(@article_comment.comment_images, used_blob_signed_ids)

        unused_blob_signed_ids = blob_signed_ids - used_blob_signed_ids # 使われていない画像のsigned_idの配列を取得
        unused_blob_delete(unused_blob_signed_ids) # 使われなかった画像のpurge処理
    end

    def handle_article_comment_images_for_update
        # article_comment_paramsメソッドにより取り出せなくなる前にblob_signed_idsを取得
        blob_signed_ids = JSON.parse(@params[:article_comment][:blob_signed_ids])

        @article_comment = ArticleComment.find(@params[:id])

        attached_signed_ids = @article_comment.comment_images.map(&:signed_id)
        image_urls = extract_s3_urls(@params[:article_comment][:comment])
        used_blob_signed_ids = get_blob_signed_id_from_url(image_urls)

        if attached_signed_ids.present?
            # 二重にアタッチしないようにするための処理
            used_attached_signed_ids = attached_signed_ids & used_blob_signed_ids
            new_blob_signed_ids = used_blob_signed_ids - used_attached_signed_ids

            attach_images_to_resource(@article_comment.comment_images, new_blob_signed_ids)

            combined_blob_signed_ids = blob_signed_ids.concat(attached_signed_ids)
            unused_blob_signed_ids = combined_blob_signed_ids - used_blob_signed_ids
        else
            attach_images_to_resource(@article_comment.comment_images, used_blob_signed_ids)

            unused_blob_signed_ids = blob_signed_ids - used_blob_signed_ids
        end
        unused_blob_delete(unused_blob_signed_ids) # 使われなかった画像のpurge処理
    end
end