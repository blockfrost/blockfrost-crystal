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

Create an initializer to configure the API key:

```crystal
Blockfrost.configure do |config|
  config.cardano_api_key = ENV.fetch("BLOCKFROST_CARDANO_API_KEY")
  config.ipfs_api_key = ENV.fetch("BLOCKFROST_IPFS_API_KEY")
end
```

## Usage

TODO: Coming soon!

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
