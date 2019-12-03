module JSON::OnSteroids::Dirty
  getter? dirty : Bool = false

  def dirty!
    unless @dirty
      @dirty = true

      parent.try &.dirty!
    end
  end

  def dirty_only
    if @dirty
      if h = as_h?
        out = JSON::OnSteroids.new

        h.each do |k,v|
          val = v.dirty_only
          out[k] = val.dup if val
        end

        out
      elsif arr = as_arr?
        JSON::OnSteroids.new(arr.map(&.dirty_only.as(JSON::OnSteroids|Nil)).compact)
      else
        self.dup
      end
    else
      nil
    end
  end

  def clean!
    return unless dirty?

    @dirty = false

    if h = as_h?
      h.each_value(&.clean!)
    elsif arr = as_arr?
      arr.each(&.clean!)
    end
  end

end