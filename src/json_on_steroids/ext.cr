struct JSON::Any
  # Convert the current JSON::Any structure into an action movie hero
  #
  # See `JSON::OnSteroids` for more informations
  def on_steroids!
    JSON::OnSteroids.new(self)
  end
end
