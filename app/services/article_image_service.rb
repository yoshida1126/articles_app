class ArticleImageService
    include ImageUtils
    include ArticleDraftParams::ArticleDraftParamsPermitter
    include ArticleParams::ArticleParamsPermitter

    def initialize(user, params, action)
        @user = user
        @params = params
        @action = action
        @blob_finder = ->(blob_key) { find_blob_by_blob_key(blob_key) }
        @image_resizer = ->(tempfile) { resize_image(tempfile) }
    end

    def process
        case @action
        when :autosave_draft
            @service = UploadQuotaService.new(user: @user)
            handle_images_for_autosave_draft

            remaining_mb = @service.remaining_mb
            max_size = @service.max_size

            return [@draft, @params, remaining_mb, max_size]
        when :save_draft, :update_draft
            handle_images

            return @draft, @params
        when :commit, :update
            handle_images

            return [load_or_build_from_draft, @draft, @params]
        else
            raise "Unknown action: #{@action}"
        end
    end

    private

    def handle_images_for_autosave_draft
        blob_signed_ids = @params[:article_draft][:blob_signed_ids].present? ? JSON.parse(@params[:article_draft][:blob_signed_ids]) : []

        if @params[:article_draft][:image].present?
            resized = resize_article_header_image(@params[:article_draft][:image])

            attachable = @service.track!(resized.size)

            @params[:article_draft][:image] = resized if (attachable)
        end

        load_or_build_draft

        attach_article_images if @params[:article_draft][:content].present?
    end

    def handle_images
        blob_signed_ids = @params[:article_draft][:blob_signed_ids].present? ? JSON.parse(@params[:article_draft][:blob_signed_ids]) : []

        load_or_build_draft

        purge_article_images(blob_signed_ids)
    end

    def attach_article_images
        attached_signed_ids = @draft.article_images.present? ? @draft.article_images.map(&:signed_id) : []

        # 画像が保存されている場所のURLを取得
        image_urls = extract_s3_urls(@params[:article_draft][:content])
        # URLを元に使われている画像のblob_signed_idの配列を取得
        used_blob_signed_ids = get_blob_signed_id_from_url(image_urls, blob_finder: @blob_finder)
        # 編集後にも使われているアタッチ済みの画像を抽出
        used_attached_signed_ids = attached_signed_ids & used_blob_signed_ids
        # 記事の編集により追加された画像のアタッチ処理
        attach_images_to_resource(@draft.article_images, used_blob_signed_ids - used_attached_signed_ids, blob_finder: @blob_finder)
    end

    def purge_article_images(blob_signed_ids)
        attached_signed_ids = @draft.article_images.map(&:signed_id)
        image_urls = extract_s3_urls(@params[:article_draft][:content])
        used_blob_signed_ids = get_blob_signed_id_from_url(image_urls, blob_finder: @blob_finder)

        # 使われなかった画像や、消された画像の抽出処理
        unused_blob_signed_ids = calculate_unused_blob_signed_ids(
            blob_signed_ids, attached_signed_ids, used_blob_signed_ids
        )
        # attachments_finder は、signed_id を元に ActiveStorage::Attachment を検索するための Proc です。
        attachments_finder = ->(blob_id) { find_attachments(blob_id) }
        # 使われなかった画像や、消された画像のpurge処理
        unused_blob_delete(@draft.id, unused_blob_signed_ids, blob_finder: @blob_finder, attachments_finder: attachments_finder)
    end

    def load_or_build_draft
        if @params[:id].present? || @params[:article_draft][:draft_id].present?
            draft_id = @params[:id].present? ? @params[:id] : @params[:article_draft][:draft_id]
            @draft = @user.article_drafts.find(draft_id)
        else
            @sanitized_params = sanitized_article_draft_params(@params)
            @draft = @user.article_drafts.build(@sanitized_params)
        end
    end

    def load_or_build_from_draft
        if @draft.article.present?
            @article = @draft.article 
        else
            @article = @user.articles.build(
                article_draft: @draft
            )
            @draft.article = @article
        end

        return @article
    end
end
