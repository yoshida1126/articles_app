class UserPostLimitService
  DAILY_LIMIT = 5

  def initialize(user)
    @user = user
    @key = "user:#{@user.id}:daily_posts:#{Date.today}"
  end

  def over_limit?
    current_count >= DAILY_LIMIT
  end

  def track_post
    return if over_limit?

    $redis.incr(@key)
    expire_if_needed
  end

  def current_count
    $redis.get(@key).to_i
  end

  private

  def expire_if_needed
    seconds_until_end_of_day = (Date.tomorrow.beginning_of_day - Time.current).to_i
    $redis.expire(@key, seconds_until_end_of_day) unless $redis.ttl(@key) > 0
  end
end
