module JSON::OnSteroids::SetInPlace
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
  def set(&block)
    @raw = JSON::OnSteroids.new(yield).raw
    self.dirty!
  end

  def set(value)
    @raw = JSON::OnSteroids.new(value).raw
    self.dirty!
  end

  def delete(key : Int | String | Nil )
    if arr = as_arr?
      elm = arr[key.as(Int)]
      arr.delete_at(key.as(Int))
    elsif h = as_h?
      elm = h[key.as(String)]
      h.delete(key.as(String))
    end

    @parent = nil
    @key = nil

    elm
  end

  def delete
    if(parent = self.parent)
      parent.delete(key)
    else
      raise "Cannot delete a root document"
    end
  end
end