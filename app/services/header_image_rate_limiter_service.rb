class HeaderImageRateLimiterService
  MAX_UPDATES_PER_DAY = 5

  def self.exceeded?(user_id, image)
    return false if !image.present? 
    
    key = "user:#{user_id}:header_image_update_count:#{Date.today}"
    count = $redis.get(key).to_i
    count >= MAX_UPDATES_PER_DAY
  end

  def self.count_for_today(user_id)
    key = "user:#{user_id}:header_image_update_count:#{Date.today}"
    $redis.get(key).to_i
  end

  def self.increment(user_id)
    key = "user:#{user_id}:header_image_update_count:#{Date.today}"
    if !$redis.exists?(key)
      seconds_until_end_of_day = (Date.tomorrow.beginning_of_day - Time.current).to_i
      $redis.set(key, 1, ex: seconds_until_end_of_day)
    else
      $redis.incr(key)
    end
  end
end