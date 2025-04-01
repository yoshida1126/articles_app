require 'sidekiq/cron/job'

# Sidekiqの設定（Redisの設定）
Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://redis:6379/0' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://redis:6379/0' }
end

# Sidekiq-cronの設定（定期実行のジョブ設定）
Sidekiq::Cron::Job.create(
  name: 'Purge Unused Images - every 1 day',
  # cron: '0 0 * * *',  # 毎日0時に実行
  cron: '*/1 * * * *',
  class: 'PurgeUnusedImagesJob'  # 実行するジョブクラス名
)
