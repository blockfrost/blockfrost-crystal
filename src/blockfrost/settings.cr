module Blockfrost
  annotation CardanoNetworks
  end
  annotation RequestExceptions
  end
end

@[Blockfrost::CardanoNetworks({
  :mainnet,
  :preprod,
  :preview,
  :testnet,
})]
@[Blockfrost::RequestExceptions({
  BadRequest:  400,
  Forbidden:   403,
  NotFound:    404,
  IpBanned:    418,
  OverLimit:   429,
  ServerError: 500,
})]
module Blockfrost
  extend self

  MAX_PAGES                        = 21_474_836
  MAX_COUNT_PER_PAGE               =        100
  MAX_NUMBER_OF_PARALLEL_REQUESTS  =        200
  MAX_RETRIES_IN_PARALLEL_REQUESTS =         10

  {% begin %}
    {% cardano_networks = Blockfrost.annotation(Blockfrost::CardanoNetworks)
         .args.first.map(&.id) %}

    Habitat.create do
      setting cardano_api_key : String?,
        validation: :validate_cardano_api_key
      setting cardano_api_version : String = "v0",
        validation: :validate_api_version
      setting ipfs_api_key : String?,
        validation: :validate_ipfs_api_key
      setting ipfs_api_version : String = "v0",
        validation: :validate_api_version
      setting default_order : QueryOrder?,
        validation: :validate_order
      setting default_count_per_page : Int32?,
        validation: :validate_count_per_page
    end

    def host_for_path(
      path : String
    ) : String
      case path
      when /^ipfs/ then "https://ipfs.blockfrost.io"
      else "https://cardano-#{cardano_network}.blockfrost.io"
      end
    end

    def api_key_for_path(
      path : String
    ) : String
      case path
      when /^ipfs/
        settings.ipfs_api_key ||
          Habitat.raise_validation_error("Missing IPFS API key")
      else
        settings.cardano_api_key ||
          Habitat.raise_validation_error("Missing Cardano API key")
      end
    end

    def api_version_for_path(
      path : String
    ) : String
      case path
      when /^ipfs/ then settings.ipfs_api_version
      else settings.cardano_api_version
      end
    end

    def cardano_network : String
      api_key = settings.cardano_api_key ||
        Habitat.raise_validation_error("Missing Cardano API key")

      api_key.match(/^({{cardano_networks.join('|').id}})/).try(&.[1]).to_s
    end

    {% for method in cardano_networks %}
      def cardano_{{method.id}}? : Bool
        cardano_network == "{{method}}"
      end
    {% end %}

    def validate_cardano_api_key(value : String?)
      return unless api_key = value

      api_key.match(/^({{cardano_networks.join('|').id}})[A-Za-z0-9]{32}/) ||
        Habitat.raise_validation_error("Cardano API key is invalid")
    end

    def validate_ipfs_api_key(value : String?)
      return unless api_key = value

      api_key.match(/^ipfs[A-Za-z0-9]{32}/) ||
        Habitat.raise_validation_error("IPFS API key is invalid")
    end

    def validate_api_version(value : String)
      value.match(/^v\d+$/) ||
        Habitat.raise_validation_error(
          "API version is invalid (e.g. v0)"
        )
    end

    def validate_order(value : QueryOrder | String?)
      return unless order = value

      %w[asc desc].includes?(value.to_s) ||
        Habitat.raise_validation_error(
          "Default order is invalid (either asc or desc)"
        )
    end

    def validate_count_per_page(value : Int32?)
      return unless count = value

      (1..MAX_COUNT_PER_PAGE).includes?(count) ||
        Habitat.raise_validation_error(
          "Default count per page is invalid (min 1 and max 100)"
        )
    end
  {% end %}
end
