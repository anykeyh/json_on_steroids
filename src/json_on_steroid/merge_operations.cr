module JSON::OnSteroids::MergeOperations

  # refine this javascript object by adding only the keys which are defined by
  # the tuple
  #
  # ```
  #   json = JSON.parse(%<{"a": 1, "b": 2, "c": [1,2,3]}>).on_steroid
  #   json = json % {"a", "b"} # => {"a": 1, "b": 2}
  # ```
  def % ( t : Tuple )
    json = JSON::OnSteroids.new
    h = self.as_h
    t.each do |key|
      key = key.to_s

      if val = h[key]?
        json[key] = val.raw
      end
    end

    json
  end

  # refine this javascript object by removing the keys specified
  # in the tuple
  #
  # ```
  #   json = JSON.parse(%<{"a": 1, "b": 2, "c": [1,2,3]}>).on_steroid
  #   json = json - {"c"} # => {"a": 1, "b": 2}
  # ```
  def - ( t : Tuple )
    json = JSON::OnSteroids.new
    h = self.as_h.dup

    t.each do |key|
      h.delete(key.to_s)
    end

    h.each do |key, value|
      json[key] = value
    end

    json
  end

end