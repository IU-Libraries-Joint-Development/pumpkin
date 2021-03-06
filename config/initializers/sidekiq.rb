require_relative 'redis_config'
Sidekiq.configure_server do |config|
  config.redis = Redis.current.client.options
end

Sidekiq.configure_client do |config|
  config.redis = Redis.current.client.options
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Middleware::Server::RetryJobs, max_retries: 0
  end
end
