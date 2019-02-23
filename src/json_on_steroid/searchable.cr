# Search a key (will be improved in next releases)
module JSON::OnSteroids::Searchable
  # Explore the json until a key is found.
  #
  # ```
  #   json.dig("a.b.c") # json["a"]["b"]["c"]
  # ```
  #
  # Integers in the dig path are working on both hash and arrays:
  #
  # ```
  #  json = JSON::OnSteroids.new(a: ["b", "c"])
  #  json.dig("a.0").as_s #return "b"
  # ```
  #
  # In case your key contains a dot `.`, you may want to escape it, using `\`:
  #
  # ```
  #   json.dig("a\\.b") #< equivalent to json["a.b"]
  # ```
  #
  # To mutate straight from dig, please check `set` method
  def dig(key : String)
    mem = IO::Memory.new(key)
    dig(mem)
  end

  # :nodoc:
  # Used internally to improve performance of the dig path parsing.
  private def dig(io : IO)
    key = String.build do |str|
      escape = false
      while c = io.read_char
        if c == '\''
          escape = true
          next
        elsif c == '.' && !escape
          break
        else
          str << c
        end

        escape = false
      end
    end

    if key.empty?
      self
    else
      if as_arr?
        self[key.to_i].dig(io)
      else
        self[key].dig(io)
      end
    end
  end

  # Return the current path of this mutable object.
  # If the current object is the root object, return empty string.
  #
  # ```
  #  json["a"]["b"]["c"].path # => "a.b.c"
  #  json.path # => ""
  # ```
  def path(arr = [] of String)
    if parent = @parent
      parent.path(arr)
    else
      arr << @key.to_s
      arr.reverse.join(".")
    end
  end

end