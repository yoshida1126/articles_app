class ArticleCommentLikeRateLimiterService
  RATE_LIMIT_SECONDS = 3

  def initialize(user:, article_comment:)
    @user = user
    @article_comment = article_comment
    @key = "user:#{@user.id}:like:comment:#{@article_comment.id}"
  end

  def allowed?
    last_liked = $redis.get(@key)
    return true unless last_liked

    elapsed = Time.now.to_i - last_liked.to_i
    elapsed >= RATE_LIMIT_SECONDS
  end

  def remaining_time
    last_liked = $redis.get(@key)
    return 0 unless last_liked

    remaining = RATE_LIMIT_SECONDS - (Time.now.to_i - last_liked.to_i)
    remaining.positive? ? remaining : 0
  end

  def record_like_time
    $redis.set(@key, Time.now.to_i, ex: RATE_LIMIT_SECONDS)
  end
end
