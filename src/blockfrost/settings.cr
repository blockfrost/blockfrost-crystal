module Blockfrost
  extend self

  Habitat.create do
    setting api_key : String, validation: :validate_api_key
    setting api_version : String = "v0", validation: :validate_api_version
  end

  def network
    Habitat.raise_if_missing_settings!

    settings.api_key.match(/^((main|test)net)/).try(&.[1])
  end

  def host
    "https://cardano-#{network}.blockfrost.io"
  end

  def validate_api_key(value : String)
    value.match(/^(main|test)net[A-Za-z0-9]{32}/) ||
      Habitat.raise_validation_error(
        "The api key must start with 'mainnet' or 'testnet'"
      )
  end

  def validate_api_version(value : String)
    value.match(/^v\d$/) ||
      Habitat.raise_validation_error(
        "Not a valid API version"
      )
  end
end
