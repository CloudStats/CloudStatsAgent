class ::Array
  def sum
    inject(0, :+)
  end

  def sum2
    width = map(&:size).max

    return 0 if width.nil?

    inject [0] * width do |acc, val|
      acc.zip(val).map(&:sum)
    end
  end

  def sum_field(field)
    result = 0
    inject result do |acc, val|
      acc + val[field]
    end
  end

  def map_to_hash
    Hash[map { |x| yield x }]
  end
end
