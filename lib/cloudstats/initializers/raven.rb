require 'raven'

Raven.configure do |config|
  config.dsn = 'https://af2c37d7336b47fa81af5871515b3fc0:619611ea1fde43fd82029f4d326c697c@sentry.io/89500'
  config.excluded_exceptions = ['Errno::ETIMEDOUT', 'Errno::ENOMEM', 'Errno::ECONNRESET', 'Errno::EPIPE', 'Errno::ENOSPC', 'Net::ReadTimeout'] + Raven::Configuration::IGNORE_DEFAULT
end

Raven.tags_context version: CloudStats::VERSION, agent_environment: CloudStats::ENVIRONMENT
Raven.extra_context PublicConfig: PublicConfig, Config: Config
