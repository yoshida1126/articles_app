class UploadsController < ApplicationController
  before_action :authenticate_user!

  def track_article_images
    track_upload(:article)
  end

  def track_comment_images
    track_upload(:comment)
  end

  def remaining_quota
    type = params[:type]
    service = UploadQuotaService.new(user: current_user, type: type)

    render json: {
      type: type,
      used: service.current,
      remaining: service.remaining,
      remaining_mb: (service.remaining / 1.megabyte.to_f).round(2),
      max: service.max_size
    }
  rescue ArgumentError
    render json: { error: "無効なタイプです。" }, status: :bad_request
  end

  private

  def track_upload(type)
    byte_size = params[:byte_size].to_i
    service = UploadQuotaService.new(user: current_user, type: type)

    if service.track!(byte_size)
      render json: {
        success: true,
        remaining: service.remaining,
        remaining_mb: (service.remaining / 1.megabyte.to_f).round(2)
      }
    else
      error_message = case type.to_sym
                      when :article
                        "本日アップロード可能な画像の合計サイズを超えています。\n※記事に貼る画像は5MBまでです。"
                      when :comment
                        "本日アップロード可能な画像の合計サイズを超えています。\n※コメントに貼る画像は2MBまでです。"
                      end

      render json: { alert: error_message }, status: :forbidden
    end
  end
end
