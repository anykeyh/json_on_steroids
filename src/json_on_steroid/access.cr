# Access and mutate values
module JSON::OnSteroids::Access
  # Assume the current mutable is an hash and set a value to a given key.
  def []=(key : String, value)
    h = as_h
    h[key] = JSON::OnSteroids.new(value, self, key)
  end

  # Assume the current mutable is an array and set a value to a given key.
  def []=(key : Int, value)
    if arr = as_arr?
      arr[key] = JSON::OnSteroids.new(value, self, key)
    else
      raise("Cannot set: #{path} is not an Array.")
    end
  end

  # Assume the current mutable is an array and append a value at the end.
  def <<(value : AuthorizedSetTypes)
    if arr = as_arr?
      arr << JSON::OnSteroids.new(value)
    else
      raise("Cannot set: #{path} is not an Array.")
    end
  end

  # Assume the current mutable is an array and return the value at the key offset.
  def [](key : Int)
    if arr = as_arr?
      arr[key]
    else
      raise("Cannot fetch: #{path} is not an Array.")
    end
  end

  # Assume the current mutable is an hash and return the value under the key
  def [](key : String)
    raise("Error accessing #{key}: The parent `#{path}` is not an object") unless hash = as_h?
    k = hash.fetch(key){ raise("Key not found: #{key} (in `#{path}`)") }
  end

  # Assume the current mutable is an hash and return the value under the key, if any.
  def []?(key : String)
    if h = as_h?
      h[key]?
    else
      raise("Cannot fetch key #{key}: `#{path}` is not an object.")
    end
  end
end