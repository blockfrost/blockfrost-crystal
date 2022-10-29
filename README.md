![GitHub](https://img.shields.io/github/license/wout/blockfrost-crystal)
![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/wout/blockfrost-crystal)
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/wout/blockfrost-crystal/blockfrost-crystal%20CI)
<a href="https://fivebinaries.com/"><img src="https://img.shields.io/badge/made%20by-Five%20Binaries-darkviolet.svg?style=flat-square" /></a>

<img src="https://blockfrost.io/images/logo.svg"
       width="250"
       align="right"
       height="90">

# blockfrost-crystal

<br>

<p align="center">A Crystal SDK for Blockfrost.io API.</p>
<p align="center">
  <a href="#getting-started">Getting started</a> •
  <a href="#installation">Installation</a> •
  <a href="#usage">Usage</a>
</p>
<br>

## Getting started

To use this SDK, you first need login into to
[blockfrost.io](https://blockfrost.io) create your project to retrieve your API
key.

<img src="https://i.imgur.com/smY12ro.png">

<br>

## Installation

1. Add the dependency to your `shard.yml`:

  ```yaml
  dependencies:
    blockfrost:
      github: wout/blockfrost-crystal
  ```

2. Run `shards install`

## Usage

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

Every endpoint of the [Blockfrost API](https://docs.blockfrost.io/) is covered
by this library. It's too much to list them all here, but below are a few
examples of their usage.

### Single resources

Get the latest block:

```crystal
block = Blockfrost::Block.latest
```

Or a specific block:

```crystal
block_hash = "4ea1ba291e8eef538635a53e59fddba7810d1679631cc3aed7c8e6c4091a516a"
block = Blockfrost::Block.get(block_hash)
```

### Nested resources

To get the transaction ids of a loaded block:

```crystal
block.tx_ids
```

The same can be done in one go as well:

```crystal
Blockfrost::Block.tx_ids(block_hash)
```

This pattern is used throughout the library. There will always be a class method
and a corresponding instance method for nested resources.

Some nested resources have an additional scope parameter, like the utxos of an
asset of an address:

```crystal
address = "addr1qxqs59lphg8g6qndelq8xwqn60ag3aeyfcp33c2kdp46a09re5df3pzwwmyq..."
asset = "b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e"
utxos = Blockfrost::Address.utxos_of_asset(address, asset)
```

### Collections, ordering and pagination

Get all assets:

```crystal
assets = Blockfrost::Asset.all
```

Almost all collection methods accept three arguments for ordering and
pagination:

```crystal
assets = Blockfrost::Asset.all(
  order: "desc",
  count: 20,
  page: 1
)
```

The `order` parameter is converted to an enum in the background, so the 
underlying enum values are also accepted:

```crystal
assets = Blockfrost::Asset.all(
  order: Blockfrost::QueryOrder::DESC,
  count: 20,
  page: 1
)
```

Some endpoints don't have an order parameter, like `.previous`/`next` on blocks:

```crystal
block_height = 15243592
Blockfrost::Block.get(block_height).next(count: 5, page: 2)
```

The `transactions` method for addresses exceptionally accepts two additional
arguments:

```crystal
address = "addr1qxqs59lphg8g6qndelq8xwqn60ag3aeyfcp33c2kdp46a09re5df3pzwwmyq..."
Blockfrost::Address.transactions(
  address,
  order: "desc",
  count: 10,
  page: 1,
  from: "8929261",
  to: "9999269:10"
)
```

### Post endpoints

Submit an already serialized transaction to the network:

```crystal
tx_data = File.open("path/to/cbor_data")
Blockfrost::Transaction.submit(tx_data)
# => "d1662b24fa9fe985fc2dce47455df399cb2e31e1e1819339e885801cc3578908"
```

## Documentation

[API (main)](https://wout.github.io/blockfrost-crystal/)

## Development

Make sure you have [Guardian.cr](https://github.com/f/guardian) installed. Then
run:

```bash
$ guardian
```

This will automatically:
- run ameba for src and spec files
- run the relevant spec for any file in the src dir
- run a spec file whenever they are saved
- install shards whenever you save shard.yml

## Contributing

1. Fork it (<https://github.com/wout/blockfrost-crystal/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Wout](https://github.com/wout) - creator and maintainer
