require 'airbrake'

Airbrake.configure do |config|
  config.api_key = 'b25ddd75ab51914e86f8229e53cdea44'
  config.host    = '208.52.189.15'
  config.port    = 3001
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
