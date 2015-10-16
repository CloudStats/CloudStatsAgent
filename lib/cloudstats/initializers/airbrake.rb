require 'airbrake'

Airbrake.configure do |config|
  config.api_key = '81e6c1f54c95aa51f1898e49182482ba'
  config.host    = '40.127.109.43'
  config.port    = 3000
  config.secure  = config.port == 443
end

module Airbrake
  def self.catch(error, params={})
    Airbrake.notify_or_ignore(
      error,
      parameters: params.merge!({
        argv: ARGV,
        public_config: PublicConfig,
        config: Config,
        src_path: $SRC_PATH,
        env: ENV
      })
    )
  end
end
