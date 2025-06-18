require "./spec_helper"

describe OrderedHash do
  it "works" do
    shash = OrderedHash(String, String).new
    shash.should be_a OrderedHash(String, String)
  end

  it "can be assigned to and read from" do
    shash = OrderedHash(String, Int64).new
    shash["one"] = 1
    shash["two"] = 2
    shash["one"].should eq 1_i64
    shash["two"].should eq 2_i64
  end

  it "remembers order of assignment" do
    keys = %w{zero one two three four five six seven eight nine}
    shash = OrderedHash(String, Int32).new
    keys.each_with_index do |key, idx|
      shash[key] = idx
    end
    shash.keys.should eq keys
    shash.values.should eq (0..9).to_a
  end

  it "allows a key to be deleted" do
    keys = %w{zero one two three four five six seven eight nine}
    shash = OrderedHash(String, Int32).new
    keys.each_with_index do |key, idx|
      shash[key] = idx
    end
    shash.keys.should eq keys
    shash.delete "three"
    shash.keys.should eq keys.reject("three")
  end

  it "allows keys to be sorted" do
    keys = %w{zero one two three four five six seven eight nine}
    ordered_keys = %w{eight five four nine one seven six three two zero}
    ordered_ints = [8, 5, 4, 9, 1, 7, 6, 3, 2, 0]
    shash = OrderedHash(String, Int32).new(keys: keys, values: (0..9).to_a)
    shash.sort!
    shash.keys.should eq ordered_keys
    shash.values.should eq ordered_ints
  end

  it "can be serialized to/from JSON" do
    json_text = "{\"foo\":\"bar\",\"baz\":\"qux\"}"
    shash = OrderedHash(String, String).from_json(json_text)
    shash.keys.should eq %w{foo baz}
    shash.to_json.should eq json_text
  end
end
