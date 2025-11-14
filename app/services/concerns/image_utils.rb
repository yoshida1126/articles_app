module ImageUtils
    # ヘッダー画像のリサイズ
    def resize_article_header_image(image, processor_proc: nil)
        return unless image.present?

        processed = if processor_proc
                      processor_proc.call(image.tempfile)
                    else
                      ImageProcessing::MiniMagick
                        .source(image.tempfile)
                        .resize_to_limit(1024, 1024)
                        .call
                    end
        
        ActionDispatch::Http::UploadedFile.new(
            filename: image.original_filename,
            type: image.content_type,
            tempfile: processed
        )                                                                                  
    end

    # 以下、記事本文中やコメント本文中の画像に関する処理

    # blob_finder は ActiveStorage::Blob.find_signed を差し替えるための依存性注入です。
    # テスト時にモック可能なように関数として渡せるようにしています。
    def attach_images_to_resource(resource, used_blob_signed_ids, blob_finder:)
        return unless used_blob_signed_ids.present?

        used_blob_signed_ids.each do |blob_key|
            blob = blob_finder.call(blob_key)

            next if resource.attachments.any? { |att| att.blob_id == blob.id }

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
  
    def get_blob_signed_id_from_url(image_urls,  blob_finder:)
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
            blob = blob_finder.call(path)       
            used_blob_signed_ids.push(blob.signed_id) if blob.present?
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
  
    # attachments_finder は ActiveStorage::Attachment.where を差し替えるための依存性注入です。
    # テスト時にモック可能なように関数として渡せるようにしています。
    # アタッチされていない画像に対しては不要なため、デフォルトは nil にしています。
    def unused_blob_delete(unused_blob_signed_ids, blob_finder:, attachments_finder: nil)
        return unless unused_blob_signed_ids.present?
      
        unused_blob_signed_ids.each do |blob_key|
            blob = blob_finder.call(blob_key)
            next unless blob.present?

            attachments = attachments_finder&.call(blob.id)

            if attachments.present?
                # アタッチメントを purge して関連付けを削除
                attachments&.each(&:purge_later)
            else
                blob.purge_later
            end
        end
    end

    def find_blob_by_blob_key(blob_key)
        ActiveStorage::Blob.find_signed(blob_key)
    end

    def find_attachments(blob_id)
        ActiveStorage::Attachment.where(blob_id: blob_id) 
    end

    def calculate_total_image_size(blob_ids)
        blob_ids.sum { |blob_id|
            get_image_size_from_blob_id(blob_id)
        }
    end

    def get_image_size_from_blob_id(blob_id)
        blob = ActiveStorage::Blob.find_signed(blob_id)
        blob ? blob.byte_size : 0
    end
end