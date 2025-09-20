class LikeRateLimiterService
  RATE_LIMIT_SECONDS = 3

  def initialize(user:, article:)
    @user = user
    @article = article
    @key = "user:#{@user.id}:like:#{@article.id}"
  end

  # ユーザーが「いいね」操作を行ってもよいか判定する
  # 指定されたインターバル時間を経過していなければ false を返す
  def allowed?
    last_liked = $redis.get(@key)
    return true unless last_liked

    elapsed = Time.now.to_i - last_liked.to_i

    elapsed >= RATE_LIMIT_SECONDS
  end

  # 制限が解除されるまでの残り秒数を返す（制限がなければ 0
  def remaining_time
    last_liked = $redis.get(@key)
    return 0 unless last_liked

    remaining = RATE_LIMIT_SECONDS - (Time.now.to_i - last_liked.to_i)
    remaining.positive? ? remaining : 0
  end

  # 現在時刻を「最後にいいねした時刻」として Redis に保存
  # ex オプションで自動削除されるため、定期的なクリーンアップ不要
  def record_like_time
    $redis.set(@key, Time.now.to_i, ex: RATE_LIMIT_SECONDS)
  end
end
