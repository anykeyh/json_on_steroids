module JSON::OnSteroids::InPlace

  def set(value)
    @raw = JSON::OnSteroids.new(value).raw

    self.dirty!
    self
  end

  # Mutate in place a value.
  #
  # Example:
  #
  # ```
  #   # increment by one a visitor counter
  #   json.dig("data.visitors.count").set(&.as_i.+(1))
  # ```
  #
  # Other example:
  #
  # ```
  #  json["some"]["array"].as_arr.each{ |x| x.set("Hellow #{x.to_s}") }
  # ```
  #
  # Any authorized value can be passed (see JSON::Any::Mutable::AuthorizedSetTypes)
  def set
    @raw = JSON::OnSteroids.new( yield(self) ).raw

    self.dirty!
    self
  end


  def delete(key : Int | String | Nil )
    if arr = as_arr?
      elm = arr[key.as(Int)]
      arr.delete_at(key.as(Int))
    elsif h = as_h?
      elm = h[key.as(String)]
      h.delete(key.as(String))
    else
      raise "Cannot delete key `#{@key}`: not and object or an array"
    end

    dirty!

    elm
  end

  def delete
    raise "Cannot delete the root document" unless (parent = self.parent)

    parent.delete(key)

    @parent = @key = nil

    self
  end
end