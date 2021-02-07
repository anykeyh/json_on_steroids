module JSON::OnSteroids::MergeOperations

  # return a JSON object containing only the JSON fields requested in the argument enumerable
  #
  # ```
  #   json = JSON.parse(%<{"a": 1, "b": 2, "c": [1,2,3]}>).on_steroid
  #   json = json % {"a", "b"} # => {"a": 1, "b": 2}
  # ```
  def % ( t : Enumerable )
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

  # return a JSON object removing the JSON fields defined by the argument enumerable
  #
  # ```
  #   json = JSON.parse(%<{"user": "yacine", "password": "helloworld"}>).on_steroid
  #   json = json - {:password} # => {"a": 1, "b": 2}
  # ```
  def - ( t : Enumerable )
    h = self.as_h.dup

    t.each{ |key| h.delete(key.to_s) }

    JSON::OnSteroids.new(h)
  end

  def merge!(x : NamedTuple)
    x.each{ |k,v| self[k.to_s] = v }
    self
  end

  def merge(x : NamedTuple)
    json = JSON::OnSteroids.new(self)
    x.each{ |k,v| json[k.to_s] = v }
    json
  end

  def merge!(x : JSON::OnSteroids|JSON::Any)
    x.as_h.each{ |k,v| self[k.to_s] = v }
    self
  end

  def merge(x : JSON::OnSteroids|JSON::Any)
    json = JSON::OnSteroids.new(self)
    x.as_h.each{ |k,v| json[k.to_s] = v }
    json
  end

end
