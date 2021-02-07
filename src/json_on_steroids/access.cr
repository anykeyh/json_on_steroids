# Access and mutate values
module JSON::OnSteroids::Access
  # Assume the current mutable is an hash and set a value to a given key.
  def []=(key : String, value)
    h = as_h
    obj = JSON::OnSteroids.new(value, self, key)
    obj.dirty!
    h[key] = obj
  end

  # Assume the current mutable is an array and set a value to a given key.
  def []=(key : Int, value)
    if arr = as_arr?
      obj = JSON::OnSteroids.new(value, self, key)
      arr[key] = obj
      self.dirty!
    else
      raise("Cannot set: #{path} is not an Array.")
    end
  end

  # Create empty array for a specific key
  def create_arr(key : String | Int)
    self[key] = [] of JSON::OnSteroids
    self[key]
  end

  # Create empty obj at a specific key
  def create_obj(key : String | Int)
    self[key] = {} of String => JSON::OnSteroids
    self[key]
  end

  # Assume the current mutable is an array and append a value at the end.
  def <<(value)
    if arr = as_arr?
      obj = JSON::OnSteroids.new(value)
      arr << obj
      self.dirty!
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
    fetch(key){ raise("Key not found: #{key} (in `#{path}`)") }
  end

  # Assume the current mutable is an hash and return the value under the key, if any.
  def []?(key : String)
    fetch(key){ nil }
  end

  def fetch(key : String, &block)
    raise("Error accessing #{key}: The parent `#{path}` is not an object") unless hash = as_h?
    hash.fetch(key){ yield }
  end

end
