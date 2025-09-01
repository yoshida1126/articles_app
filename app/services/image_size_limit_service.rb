class ImageSizeLimitService
    include ImageUtils

    def initialize(content)
        @content = content
        @blob_finder = ->(blob_key) { find_blob_by_blob_key(blob_key) }
    end

    def process
        image_urls = extract_s3_urls(@content)

        blob_ids = get_blob_signed_id_from_url(image_urls, blob_finder: @blob_finder)
        return 0 unless blob_ids.any?

        calculate_total_image_size(blob_ids)
    end
end
