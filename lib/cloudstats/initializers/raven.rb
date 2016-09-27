require 'raven'

Raven.configure do |config|
  config.dsn = 'https://af2c37d7336b47fa81af5871515b3fc0:619611ea1fde43fd82029f4d326c697c@sentry.io/89500'
end

Raven.tags_context version: CloudStats::VERSION, agent_environment: CloudStats::ENVIRONMENT
