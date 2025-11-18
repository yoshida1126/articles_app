class UploadsController < ApplicationController
  before_action :authenticate_user!

  def track_images
    track_upload
  end

  def remaining_quota
    service = UploadQuotaService.new(user: current_user)

    render json: {
      max: service.max_size,
      used: service.current,
      remaining: service.remaining,
      remaining_mb: (service.remaining / 1.megabyte.to_f).round(2)
    }
  rescue ArgumentError
    render json: { error: "無効なタイプです。" }, status: :bad_request
  end

  private

  def track_upload
    byte_size = params[:byte_size].to_i
    service = UploadQuotaService.new(user: current_user)

    if service.track!(byte_size)
      render json: {
        success: true,
        max_size: service.max_size,
        remaining_mb: (service.remaining / 1.megabyte.to_f).round(2)
      }
    else
      error_message = "本日アップロード可能な画像の合計サイズを超えています。"

      render json: { alert: error_message }, status: :forbidden
    end
  end
end
