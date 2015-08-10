class ::Hash
  def map_to_hash
    Hash[map { |k, v| yield k, v }]
  end

  def to_json
    JSON.generate(self)
  end
end
