class ::Hash
  def map_to_hash
    Hash[map { |k, v| yield k, v }]
  end

  def to_json
    JSON.generate(self)
  end

  def deep_merge!(second)
    merger = proc { |_key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
    self.merge!(second, &merger)
  end
end
