# OrderedHash

A Crystal class that acts as a Hash, but remembers the order of key inserts and returns the
keys in that same order.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     ordered_hash:
       github: plambert/ordered_hash.cr
   ```

2. Run `shards install`

## Usage

```crystal
require "ordered_hash"

hash = OrderedHash(String, String).new
hash["wednesday"] = "piano lesson"
hash["thursday"] = "guitar lesson"

hash.keys # ==> ["wednesday", "thursday"] # _always_ will return in this order!

new_hash = hash.sort
new_hash.keys # ==> ["thursday", "wednesday"] # the keys have been sorted, so will _always_ return in this order
```

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/plambert/ordered_hash.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Paul M. Lambert](https://github.com/plambert) - creator and maintainer
