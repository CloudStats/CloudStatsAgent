module CloudStats
  def self.server_key(info)
    server_key_path = Config[:server_key_path]

    if File.exists? server_key_path
      stored_key = File.read(server_key_path).strip
    end

    valid = !stored_key.nil? && stored_key.length == 32

    if valid
      stored_key
    else
      key = self.generate_server_key(info)
      File.write(server_key_path, key)
      key
    end
  end

  def self.generate_server_key(info)
    md5    = Digest::MD5.new
    random = Random.new.bytes(10)
    data   = info[:network].to_s
    md5 << (random + data)
    md5.hexdigest
  end
end
