class LikeRateLimiterService
  def initialize(user_id:, article_id:, interval: 3)
    @user_id = user_id
    @article_id = article_id
    @interval = interval
    @key = "user:#{@user_id}:like:#{@article_id}"
  end

  def allowed?
    last_liked = $redis.get(@key)
    return true unless last_liked

    Time.now.to_i - last_liked.to_i >= @interval
  end

  def remaining_time
    last_liked = $redis.get(@key)
    return 0 unless last_liked

    remaining = @interval - (Time.now.to_i - last_liked.to_i)
    remaining.positive? ? remaining : 0
  end

  def record_like_time
    $redis.set(@key, Time.now.to_i, ex: @interval)
  end
end
