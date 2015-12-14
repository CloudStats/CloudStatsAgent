require 'fileutils'

module CloudStats
  def self.server_key(info)
    stored_key = CloudStats.server_key_from_file(Config[:server_key_path])
    old_stored_key = CloudStats.server_key_from_file(Config[:old_server_key_path])

    valid = stored_key && stored_key.length == 32

    if valid
      stored_key
    else
      key = old_stored_key || self.generate_server_key(info)
      dirname = File.dirname(Config[:server_key_path])
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
      File.write(Config[:server_key_path], key)
      key
    end
  end

  def self.server_key_from_file(file)
    if File.exists? file
      File.read(file).strip
    end
  end

  def self.generate_server_key(info)
    SecureRandom.urlsafe_base64(254)
  end
end
