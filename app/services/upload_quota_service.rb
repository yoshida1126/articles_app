class UploadQuotaService
  def initialize(user:)
    @user = user
    @key = "upload_images_quota:#{user.id}:#{Date.today}"
    @max_size = 10.megabytes
  end

  def max_size
    (@max_size / 1.megabyte.to_f).round(0)
  end

  def current
    $redis.get(@key).to_i
  end

  def remaining
    [@max_size - current, 0].max
  end

  def remaining_mb
    remaining_mb = (remaining / 1.megabyte.to_f)
    remaining_mb.round(1) == 10.0  ? remaining_mb.round(0) : remaining_mb.round(2)
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

