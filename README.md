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

To use this SDK, you first need to log in to
[blockfrost.io](https://blockfrost.io) to create your project to retrieve your
API key.

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

Every endpoint of the [Blockfrost API](https://docs.blockfrost.io/) is covered
by this library. It's too much to list them all here, but below are a few
examples of their usage.

### Configuration

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

There are several configuration options available. Here's an overview with
some added information:

```crystal
Blockfrost.configure do |config|
  # an API KEY starting with "testnet", "preview", "preprod" or "mainnet"
  config.cardano_api_key = ENV.fetch("BLOCKFROST_CARDANO_API_KEY")

  # the api version of the Cardano enpoints (currently only "v0") 
  config.cardano_api_version = "v0"

  # an API KEY starting with "ipfs"
  config.ipfs_api_key = ENV.fetch("BLOCKFROST_IPFS_API_KEY")

  # the api version of the IPFS enpoints (currently only "v0") 
  config.ipfs_api_version = "v0"

  # Blockfrost::QueryOrder::ASC or Blockfrost::QueryOrder::DESC
  config.default_order = Blockfrost::QueryOrder::DESC

  # default count per page in collection endpoints (min: 1; max: 100; default: 100)
  config.default_count_per_page = 42

  # number of times to retry in concurrent requests (min: 0; max: 10; default: 5)
  config.retries_in_concurrent_requests = 5

  # sleep between retries in concurrent requests (in ms; min: 0; default: 500)
  config.validate_sleep_between_retries_ms = 1000
end
```

To use one or more different configuration values locally in your code, use the
`temp_config` method with a block:
 
```crystal
# any code here will use the global configuration

Blockfrost.temp_config(cardano_api_key: "preprodAbC...xYz") do
  # this code will use the "preprodAbC...xYz" api key
end

# any code following here will use the global configuration again
```

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

**NOTE**: *The `count` parameter should be a value between `1` and `100`. Lower
or higher values will be coerced to fit within that range.*

The `order` parameter is converted to an enum in the background, so the 
underlying enum values are also accepted:

```crystal
assets = Blockfrost::Asset.all(
  order: Blockfrost::QueryOrder::DESC,
  count: 20,
  page: 1
)
```

**NOTE**: *Using the enum values is considered the safer option. If a string with
a typo is passed (e.g. "decs"), the `default_order` from the settings will be
used, whereas passing an enum with a typo will fail to compile. It's a choice
of security over convenience.*

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

Ordering and count per page can also be configured with the following two
settings:

```crystal
Blockfrost.configure do |config|
  # Blockfrost::QueryOrder::ASC or Blockfrost::QueryOrder::DESC
  config.default_order = Blockfrost::QueryOrder::DESC

  # minimum 1 and maximum 100
  config.default_count_per_page = 42
end
```

### Concurrency for large collections

Every method accepting pagination parameters will also have a method overload
accepting a `pages : Range` argument instead of `page : Int32`:

```crystal
assets = Blockfrost::Asset.all(pages: 1..10)
assets.size
# => 1000
```

In the background, this method will make concurrent requests fetching 100
records for every single page number in the range. Then those results are
concatenated into one big array and returned as the result.

Except for `count` and `page`, all other arguments are also still accepted. So
the results can also be ordered:

```crystal
assets = Blockfrost::Asset.all(1..10, "asc")
```

Or with nested resources:

```crystal
pool_id = "pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy"
events = Blockfrost::Pool.history(pool_id, pages: 1..5)
```

It also handles all possible exceptions of the Blockfrost API. If your account
is temporarily rate-limited (`Blockfrost::Client::OverLimitException`), it will
retry 10 times and raise anyway after that. All other exceptions will be raised
immediately.

There are two settings related to rate-limiting:

```crystal
Blockfrost.configure do |config|
  # minimum 0, maximum 10; defaults to 10
  config.retries_in_concurrent_requests = 5

  # minimum 0, no maximum; defaults to 500
  config.validate_sleep_between_retries_ms = 1000
end
```

### Post endpoints

Submit an already serialized transaction to the network:

```crystal
tx_data = File.open("path/to/cbor_data")
Blockfrost::Transaction.submit(tx_data)
# => "d1662b24fa9fe985fc2dce47455df399cb2e31e1e1819339e885801cc3578908"
```

### IPFS endpoints

Add an object to IPFS:

```crystal
object = Blockfrost::IPFS.add("path/to/file")
```

Pin an object to local storage:

```crystal
result = object.pin
result.state
# => Blockfrost::IPFS::Pin::State::Queued
```

Or alternatively (and the same):

```crystal
Blockfrost::IPFS::Pin.add(object.ipfs_hash)
```

To get all pinned objects:

```crystal
Blockfrost::IPFS::Pin.all
```

Finally, to remove a pin:

```crystal
Blockfrost::IPFS::Pin.remove(ipfs_hash)
```

As expected the instance method is also available on a pin:

```crystal
pin = Blockfrost::IPFS::Pin.get(ipfs_hash)
result = pin.remove
result.state
# => Blockfrost::IPFS::Pin::State::Unpinned
```

### Network selection

The Cardano network is selected based on the API key. If the configured API key starts with `preprod...`, then the **preprod** network will be used.

There are a few helper methods available to verify which network is selected.
For example, to get the current network:

```crystal
Blockfrost.configure do |config|
  config.cardano_api_key = "preprodsSDBoik1wn1NxxhB8GB0Bcv7LuarFAKE"
end

Blockfrost.cardano_network
# => "preprod"
```

Additionally, there are also methods to test against the current network:

```crystal
Blockfrost.cardano_mainnet?
# => false
Blockfrost.cardano_preprod?
# => true

Blockfrost.temp_config(cardano_api_key: "mainnetsSDBoik1wn1NxxhB8GB0Bcv7LuarFAKE") do
  Blockfrost.cardano_mainnet?
  # => true
end

Blockfrost.cardano_mainnet?
# => false
```

### Exception handling

All exceptions from the Blockfrost API can be caught with:

```crystal
begin
  # do something
rescue e : Blockfrost::RequestException
  puts e.message
end
```

Or with more specificity:

```crystal
begin
  # do something
rescue e : Blockfrost::Client::BadRequestException
  puts "Bad request (400)"
rescue e : Blockfrost::Client::ForbiddenException
  puts "Authentication secret is missing or invalid (403)"
rescue e : Blockfrost::Client::NotFoundException
  puts "Component not found (404)"
rescue e : Blockfrost::Client::IpBannedException
  puts "IP has been auto-banned for extensive sending of requests after usage limit has been reached (418)"
rescue e : Blockfrost::Client::OverLimitException
  puts "Usage limit reached (429)"
rescue e : Blockfrost::Client::ServerErrorException
  puts "Internal Server Error (500)"
end
```

## Documentation

- [API (main)](https://wout.github.io/blockfrost-crystal/)
- [Blockfrost API](https://docs.blockfrost.io/)

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
3. Test your changes (`crystal spec`, `crystal tool format` and `bin/ameba`)
4. Commit your changes (`git commit -am 'feat: something new'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request

**NOTE**: *Please have a look at
[conventional commits](https://www.conventionalcommits.org/en/v1.0.0/) for
commit messages.*

## Contributors

- [Wout](https://github.com/wout) - creator and maintainer
