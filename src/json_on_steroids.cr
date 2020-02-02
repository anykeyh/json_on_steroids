require "json"

module JSON #< For crystal docs
end

class JSON::OnSteroids
  VERSION = 0.1
end

require "./json_on_steroids/*"

# Handle JSON into a mutable structure, and much more.
class JSON::OnSteroids
  UTC_ISO_FORMAT = "%FT%T.%LZ"

  # Wrapped content
  alias WrappedPrimitive = Bool | Int64 | Int32 | Float32 | Float64 | String | Nil | Time

  # Combination of WrappedPrimitive, Array and Hash
  alias RawWrappedValue = WrappedPrimitive  | Array(JSON::OnSteroids) | Hash(String, JSON::OnSteroids)

  # Authorized input used in []=, constructor and set
  alias AuthorizedSetTypes = WrappedPrimitive | JSON::Any | JSON::OnSteroids | RawWrappedValue

  # The raw data stored into this wrapper
  getter raw : RawWrappedValue

  # The path to the parent if any
  getter parent : JSON::OnSteroids? = nil

  # Key for this object, if any. String if it belongs to an hash, integer if it belongs to an array
  # if the element is root, key is set to nil.
  getter key : Union(String, Int32, Nil) = nil

  include Access
  include Searchable
  include InPlace
  include Dirty
  include MergeOperations

  def wrap(hash : Hash(String, _))
    raw = @raw = {} of String => self

    hash.each do |k,v|
      raw[k] = JSON::OnSteroids.new(v, self, k)
    end
  end

  def wrap(tuple : NamedTuple)
    raw = @raw = {} of String => self

    tuple.each do |k, v|
      raw[k.to_s] = JSON::OnSteroids.new(v, self, k.to_s)
    end
  end

  def wrap(array : Array(T)) forall T
    raw = @raw = Array(self).new(initial_capacity: array.size)

    array.each_with_index do |it, idx|
      raw << JSON::OnSteroids.new(it, self, idx)
    end
  end

  def initialize(**tuple)
    @parent = nil

    wrap(tuple)
  end

  def initialize(container :  NamedTuple | Array | Hash, @parent = nil, @key = nil)
    wrap(container)
  end

  def initialize(json_any : JSON::OnSteroids, @parent = nil, @key = nil)
    @raw = json_any.raw.dup
  end

  # Initialize by passing a JSON::Any object
  def initialize(json_any : JSON::Any, @parent = nil, @key = nil)
    case json_any.raw
    when Hash
      wrap(json_any.as_h)
    when Array
      wrap(json_any.as_a)
    when Float
      @raw = json_any.as_f
    when Number
      @raw = json_any.as_i64
    when String
      @raw = json_any.as_s
    when Bool
      @raw = json_any.as_bool
    when Nil
      @raw = nil
    else
      raise "Type non supported: #{json_any.raw.class}"
    end
  end

  # Basic initalization with a primitive
  def initialize(@raw : WrappedPrimitive, @parent = nil, @key = nil)
  end


  {% for k,v in {s: String, h: Hash(String, JSON::OnSteroids), b: Bool, arr: Array(JSON::OnSteroids), nil: Nil } %}
    def as_{{k.id}}?
      @raw.as?({{v.id}})
    end

    def as_{{k.id}}
      @raw.as({{v.id}})
    end
  {% end %}

  def as_number?
    @raw.as?(Number)
  end

  def as_i
    Int64.new(@raw.as(Number))
  end

  def as_i64
    Int64.new(@raw.as(Number))
  end

  def as_i32
    Int32.new(@raw.as(Number))
  end

  def as_f #< alias
    as_f64
  end

  def as_f64
    Float64.new(@raw.as(Number))
  end

  def as_f32
    Float32.new(@raw.as(Number))
  end

  def as_t?
    if s = @raw.as_s?
      Time.parse(s)
    end
  rescue
    nil
  end

  def as_t
    Time.parse(@raw.as_s)
  end

  private def escape(x)
    case x
    when String
      x.to_json
    when Time
      "\"" + x.to_utc.to_s(UTC_ISO_FORMAT) + "\""
    else
      x.to_s
    end
  end

  def to_s(io)
    case raw = @raw
    when Hash
      io << '{'
      raw.each_with_index do |(k,v), index|
        io << ',' unless index == 0
        io << escape(k)
        io << ':'
        v.inspect(io)
      end
      io << '}'
    when Array
      io << '['
      raw.each_with_index do |v, index|
        io << ',' unless index == 0
        io << escape(v)
      end
      io << ']'
    when Nil
      io << "null"
    else
      io << escape(raw)
    end
  end

  def self.parse(s : String)
    JSON.parse(s).on_steroids!
  end

  def to_json
    to_s
  end

  def inspect(io)
    io << "JSON::OnSteroids(dirty: #{dirty?.inspect})>" unless @parent

    to_s(io)
  end

end
