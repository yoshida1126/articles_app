class RateLimiter
  LIMIT = 30
  WINDOW = 60

  def initialize(app)
    @app = app
  end

  def call(env)
    return @app.call(env) if Rails.env.test?

    ip = env['REMOTE_ADDR']
    key = "access:#{ip}"

    count = $redis.incr(key)
    $redis.expire(key, WINDOW) if count == 1

    if count > LIMIT
      return [
        429,
        { 'Content-Type' => 'text/plain' },
        ["Too many requests. Please try again later."]
      ]
    end

    @app.call(env)
  end
end
