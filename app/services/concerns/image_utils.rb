module ImageUtils
    # ヘッダー画像のリサイズ

    def resize_article_header_image(params)
        if params[:image]
          params[:image].tempfile = ImageProcessing::MiniMagick.source(params[:image].tempfile).resize_to_limit(1024,
                                                                                                                1024).call
        end
        params
    end

    def resize_and_attach_article_header_image
        # 使わなくなったヘッダー画像の削除
        @article.image.purge

        # 新しいヘッダー画像のリサイズ
        params = resize_article_header_image(article_params)

        #新しいヘッダー画像のアタッチ
        @article.image.attach(params[:image])
    end

    # 記事本文中やコメント本文中の画像に関する処理

    def attach_images_to_resource(resource, used_blob_signed_ids)
        return unless used_blob_signed_ids.present?

        used_blob_signed_ids.each do |signed_id|
            blob = ActiveStorage::Blob.find_signed(signed_id)
            resource.attach(blob) if blob.present?
        end
    end
  
    def extract_s3_urls(content)
        # S3のURLにマッチする正規表現
        # regex = /https:\/\/[a-zA-Z0-9\-]+\.s3\.[a-zA-Z0-9\-]+\.amazonaws\.com\/[^\s]+/
        regex = %r{rails/active_storage/blobs/[A-Za-z0-9-]+/[^\s]+} # ローカルの場合
      
        # contentからS3のURLを全て抽出し、配列で返す
        content.scan(regex)
    end
  
    def get_blob_signed_id_from_url(image_urls)
        return [] unless image_urls.present?
      
        used_blob_signed_ids = []
        image_urls.each do |url|
            # URLからS3のパス部分を取り出す（バケット名以降）
            # uri = URI.parse(url)
            # path = uri.path.sub(/^\//, '')  # 先頭のスラッシュを削除してパス部分を取得
            # 上記はS3のURL用の処理 以下はローカルの画像URLの処理
  
            # URLからパス部分を取り出す（/rails/active_storage/blobs/以降とファイル名より前の部分）
            # path = url.sub('/rails/active_storage/blobs/', '').split('/').first
            path = url.match(%r{rails/active_storage/blobs/([^/]+)/})[1]
      
            # ActiveStorage::Blobをパスで検索
            blob = ActiveStorage::Blob.find_signed(path)
            if blob
                used_blob_signed_ids.push(blob.signed_id)
            end
        end
        used_blob_signed_ids
    end

    def calculate_unused_blob_signed_ids(blob_signed_ids, attached_signed_ids, used_blob_signed_ids)
        combined_blob_signed_ids = if attached_signed_ids.present?
                                     blob_signed_ids.concat(attached_signed_ids)
                                   else
                                     blob_signed_ids
                                   end
        combined_blob_signed_ids - used_blob_signed_ids
    end
  
    def unused_blob_delete(unused_blob_signed_ids)
        return unless unused_blob_signed_ids.present?
      
        unused_blob_signed_ids.each do |signed_id|
            blob = ActiveStorage::Blob.find_signed(signed_id)
            attachments = ActiveStorage::Attachment.where(blob_id: blob.id) if blob.present?
      
            if attachments.present?
                # 各アタッチメントを purge して関連付けを削除
                attachments.each(&:purge_later)
            elsif blob.present?
                blob.purge_later
            end
        end
    end
end