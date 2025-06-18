# A class that acts both like a hash and an array, where the order of key insertion is
# remembered.
#
#     require "ordered_hash"
#
#     shash = OrderedHash(String, String).new
#     shash["foo"] = "bar"
#     shash["baz"] = "qux"
#
#     shash["foo"]            # ==> "bar"
#     shash["baz"]?           # ==> "qux"
#     shash["lemur"]?         # ==> Nil
#
#     shash[0]                # ==> "bar"
#     shash.size              # ==> 2
#     shash.keys              # ==> ["foo", "baz"]
#     shash.values            # ==> ["bar", "qux"]
#
class OrderedHash(K, V)
  VERSION = "0.1.0"

  @key_values : Array({key: K, value: V})
  @key_indices : Hash(K, Int32)

  # Create an empty OrderedHash
  def initialize
    @key_values = Array({key: K, value: V}).new
    @key_indices = Hash(K, Int32).new
  end

  # Create a OrderedHash from an array of NamedTuples ({key: K, value: V})
  def initialize(@key_values)
    @key_indices = Hash(K, Int32).new(@key_values.size)
    @key_values.keys.each_with_index do |key, idx|
      @key_indices[key] = idx
    end
  end

  # Create a OrderedHash from an array of Tuples ({K, V})
  def initialize(key_value_list : Array({K, V}))
    @key_values = Array({key: K, value: V}).new(key_value_list.size)
    @key_indices = Hash(K, Int32).new(key_value_list.size)
    idx = 0
    key_value_list.each do |kv_pair|
      @key_values << {key: kv_pair[0], value: kv_pair[1]}
      @key_indices[kv_pair[0]] = idx
      idx += 1
    end
  end

  # Create a OrderedHash from a Hash(K, V); the initial order will be somewhat random
  def initialize(hash : Hash(K, V))
    @key_values = Array({key: K, value: V}).new(hash.size)
    @key_indices = Hash(K, Int32).new(hash.size)
    idx = 0
    hash.each_pair do |key, value|
      @key_values << {key: key, value: value}
      @key_indices[key] = idx
      idx += 1
    end
  end

  # Create a OrderedHash from an Array(K) of keys and corresponding Array(V) of values of exactly equal length
  def initialize(*, keys : Array(K), values : Array(V))
    raise ArgumentError.new "expected keys array and values array to be equal size" unless keys.size == values.size
    @key_values = Array({key: K, value: V}).new(keys.size)
    @key_indices = Hash(K, Int32).new(keys.size)
    keys.each_with_index do |key, idx|
      @key_values << {key: key, value: values[idx]}
      @key_indices[key] = idx
    end
  end

  # Create a OrderedHash from an Array(K) of keys, calling a block for each value
  def initialize(*, keys : Array(K), &block : K -> V)
    @key_values = Array({key: K, value: V}).new(keys.size)
    @key_indices = Hash(K, Int32).new(keys.size)
    keys.each_with_index do |key, idx|
      @key_values << {key: key, value: block.call(key)}
      @key_indices[key] = idx
    end
  end

  # Create an empty OrderedHash with a specified initial capacity
  def initialize(initial_capacity : Int)
    @key_values = Array({key: K, value: V}).new(initial_capacity)
    @key_indices = Hash(K, Int32).new(initial_capacity)
  end

  def_hash @key_values

  # Create a new OrderedHash with the keys ordered via Array(K).sort
  def sort
    # ameba:disable Naming/BlockParameterName
    self.class.new @key_values.sort { |a, b| a[:key] <=> b[:key] }
  end

  # Sort the keys in place via Array(K).sort
  def sort!
    # ameba:disable Naming/BlockParameterName
    @key_values.sort! { |a, b| a[:key] <=> b[:key] }
    @key_values.each_with_index do |kv_pair, idx|
      @key_indices[kv_pair[:key]] = idx
    end
  end

  # The number of entries in the OrderedHash
  def size : Int32
    @key_indices.size
  end

  # Set the value at key; adds key to the end of the ordered list if it does not already exist in
  # the OrderedHash
  def []=(key : K, value : V) : V
    if @key_indices.has_key? key
      @key_values[@key_indices[key]] = {key: key, value: value}
    else
      @key_values << {key: key, value: value}
      @key_indices[key] = @key_indices.size
    end
    value
  end

  # Set the value at index key_index; raises IndexError if the key_index is out-of-bounds
  def []=(key_index : Int32, value : K) : V
    raise IndexError.new "no entry at index #{key_index}" if key_index >= size
    @key_values[key_index] = {key: @key_values[key_index][:key], value: value}
    value
  end

  # Get the value for the given key, or raise a KeyError if no value is set for that key
  def [](key : K) : V
    raise KeyError.new "Missing OrderedHash key #{key.inspect}" unless @key_indices.has_key?(key)
    @key_values[@key_indices[key]][:value]
  end

  # Get the value for the given key, or nil if no value has been set for that key
  def []?(key : K) : V?
    if idx = @key_indices[key]?
      @key_values[idx][:value]
    else
      nil
    end
  end

  # Delete the given key, returning its prior value, or raising KeyError if it doesn't exist
  def delete(key : K) : V?
    if idx = @key_indices[key]?
      @key_values.delete_at idx
      while idx < @key_values.size
        @key_indices[@key_values[idx][:key]] -= 1
        idx += 1
      end
    else
      raise KeyError.new "Missing OrderedHash key #{key.inspect}"
    end
  end

  # Return an Array(K) of the keys in order
  def keys : Array(K)
    @key_values.map(&.[:key])
  end

  # Return an Array(V) of the values in order
  def values : Array(V)
    @key_values.map(&.[:value])
  end

  # Iterate each pair
  def each(&block : K, V ->)
    @key_values.each do |kv_pair|
      block.call kv_pair[:key], kv_pair[:value]
    end
  end

  # Iterate each key
  def each_key(&block : K ->)
    @key_values.each do |kv_pair|
      block.call kv_pair[:key]
    end
  end

  # Iterate each value
  def each_value(&block : V ->)
    @key_values.each do |kv_pair|
      block.call kv_pair[:value]
    end
  end

  # Serializes this OrderedHash into JSON.
  #
  # Keys are serialized by invoking `to_json_object_key` on them.
  # Values are serialized with the usual `to_json(json : JSON::Builder)`
  # method.
  def to_json(json : JSON::Builder) : Nil
    json.object do
      each do |key, value|
        json.field key.to_json_object_key do
          value.to_json(json)
        end
      end
    end
  end

  # Reads a OrderedHash from the given pull parser.
  #
  # Keys are read by invoking `from_json_object_key?` on this hash's
  # key type (`K`), which must return a value of type `K` or `nil`.
  # If `nil` is returned a `JSON::ParseException` is raised.
  #
  # Values are parsed using the regular `new(pull : JSON::PullParser)` method.
  def self.new(pull : JSON::PullParser)
    hash = new
    pull.read_object do |key, key_location|
      if parsed_key = K.from_json_object_key?(key)
        hash[parsed_key] = V.new(pull)
      else
        raise JSON::ParseException.new("Can't convert #{key.inspect} into #{K}", *key_location)
      end
    end
    hash
  end

  # Output a string representation similar to Hash#to_s(io)
  def to_s(io)
    io << '{'
    @key_values.each_with_index do |kv_pair, idx|
      io << ", " if idx > 0
      kv_pair[:key].inspect(io)
      io << " => "
      kv_pair[:value].inspect(io)
    end
  end
end
