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
        # 記事コメントに使用された画像だけをアタッチし、不要な画像を削除するメソッドです。
        # 画像関連のロジックは app/services/concerns/image_utils.rb に定義されています。

        # 処理の流れ：
        # 1. フォームから送られた全画像の signed_id を取得
        # 2. コメント本文内で実際に使用されている画像を抽出
        # 3. 使用されていない画像を purge（削除）

        # ※ 注意点：
        # sanitized_article_comment_paramsメソッドでパラメータがフィルタされる前に、
        # blob_signed_ids を先に取り出しておく必要があります。
        blob_signed_ids = JSON.parse(@params[:article_comment][:blob_signed_ids])

        @article_comment = @user.article_comments.new(sanitized_article_comment_params(@params))
        @article_comment.article = Article.find(@params[:article_id])

        image_urls = extract_s3_urls(@params[:article_comment][:comment])
        used_blob_signed_ids = get_blob_signed_id_from_url(image_urls, blob_finder: @blob_finder)

        attach_images_to_resource(@article_comment.comment_images, used_blob_signed_ids, blob_finder: @blob_finder)

        unused_blob_signed_ids = blob_signed_ids - used_blob_signed_ids # 使用されていない画像の signed_id を抽出

        unused_blob_delete(unused_blob_signed_ids, blob_finder: @blob_finder) # 使用されなかった画像のpurge処理
    end

    def handle_article_comment_images_for_update
        # 編集時に送信された全画像の signed_id を取得
        blob_signed_ids = JSON.parse(@params[:article_comment][:blob_signed_ids])

        @article_comment = ArticleComment.find(@params[:id])

        # すでにアタッチされている画像の signed_id を取得
        attached_signed_ids = @article_comment.comment_images.map(&:signed_id)

        # コメント本文中の S3 画像 URL を抽出し、使用されている画像の signed_id を取得
        image_urls = extract_s3_urls(@params[:article_comment][:comment])
        used_blob_signed_ids = get_blob_signed_id_from_url(image_urls, blob_finder: @blob_finder)

        if attached_signed_ids.present?
            # すでにアタッチされている画像のうち、今回も使用されている画像を特定
            used_attached_signed_ids = attached_signed_ids & used_blob_signed_ids

            # 新たにアタッチする必要がある画像を特定
            new_blob_signed_ids = used_blob_signed_ids - used_attached_signed_ids

            # 新規画像をアタッチ
            attach_images_to_resource(@article_comment.comment_images, new_blob_signed_ids, blob_finder: @blob_finder)

            # フォームで送信された画像と既存の画像をマージ
            combined_blob_signed_ids = blob_signed_ids.concat(attached_signed_ids)

            # 使用されていない画像の signed_id を抽出
            unused_blob_signed_ids = combined_blob_signed_ids - used_blob_signed_ids
        else
            # コメント編集時に初めて画像が投稿された場合（既存のアタッチ画像がない場合）
            attach_images_to_resource(@article_comment.comment_images, used_blob_signed_ids, blob_finder: @blob_finder)

            # 使用されなかった画像の signed_id を取得
            unused_blob_signed_ids = blob_signed_ids - used_blob_signed_ids
        end
        # signed_id から ActiveStorage::Attachment を検索するための Proc
        attachments_finder = ->(blob_id) { find_attachments(blob_id) }
        
        # 未使用画像の purge 処理
        unused_blob_delete(unused_blob_signed_ids, blob_finder: @blob_finder, attachments_finder: attachments_finder)
    end
end