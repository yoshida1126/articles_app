class PurgeUnusedImagesJob
  include Sidekiq::Worker

  def perform
    unused_attachments = ActiveStorage::Blob
                         .left_joins(:attachments)
                         #.where(
                         #  'active_storage_blobs.created_at >= ? ' \
                         #  'AND active_storage_blobs.created_at < ?',
                         #  1.day.ago.beginning_of_day,
                         #  1.day.ago.end_of_day
                         #)
                         .where(attachments: { id: nil })

    unused_attachments.find_each do |blob|
      blob.purge
      Rails.logger.info "Purged image: #{blob.filename} at #{Time.now}"
    end

    Rails.logger.info "Purging unused images completed at #{Time.now}"
  end
end
