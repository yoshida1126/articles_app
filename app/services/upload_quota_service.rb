class UploadQuotaService
  def initialize(user:, type:)
    @user = user
    @type = type
    @key = "#{prefix}:#{user.id}:#{Date.today}"
    @max_size = type == :article ? 5.megabytes : 2.megabytes
  end

  def current
    $redis.get(@key).to_i
  end

  def remaining
    [@max_size - current, 0].max
  end

  def track!(size)
    ensure_expire!
    if current + size > @max_size
      false
    else
      $redis.incrby(@key, size)
      true
    end
  end

  private

  def prefix
    @type == :article ? "upload_article_images_quota" : "upload_comment_images_quota"
  end

  def ensure_expire!
    if !$redis.exists?(@key) || $redis.ttl(@key) < 0
      $redis.set(@key, 0)
      $redis.expire(@key, seconds_until_end_of_day)
    end
  end

  def seconds_until_end_of_day
    (Date.tomorrow.beginning_of_day - Time.current).to_i
  end
end

