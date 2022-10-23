# blockfrost-crystal
A Crystal SDK for the Blockfrost.io API.

## Installation

1. Add the dependency to your `shard.yml`:

  ```yaml
  dependencies:
    blockfrost:
      github: wout/blockfrost-crystal
  ```

2. Run `shards install`

## Configuration

```crystal
require "blockfrost"
```

Create an initializer to configure the global API key(s):

```crystal
# e.g. config/blockfrost.cr
Blockfrost.configure do |config|
  config.cardano_api_key = ENV.fetch("BLOCKFROST_CARDANO_API_KEY")
  config.ipfs_api_key = ENV.fetch("BLOCKFROST_IPFS_API_KEY")
end
```

Or wrap your code in a block where different credentials are required:

```crystal
Blockfrost.temp_config(cardano_api_key: "testnetAbC...xYz") do
  # your code here
end
```

## Usage

```crystal
epochs = Blockfrost::Epoch.all
```

TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/wout/blockfrost-crystal/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Wout](https://github.com/wout) - creator and maintainer
