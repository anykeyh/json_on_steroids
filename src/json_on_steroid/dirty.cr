module JSON::OnSteroids::Dirty
  getter? dirty : Bool = false

  def dirty!
    unless @dirty
      @dirty = true

      parent.try &.dirty!
    end
  end

  def clean!
    return unless dirty?

    @dirty = false

    if h = as_h?
      h.each_values(&.clean!)
    elsif arr = as_arr?
      arr.each(&.clean!)
    end
  end

end