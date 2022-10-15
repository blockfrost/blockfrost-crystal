module Blockfrost
  extend self

  {% begin %}
    {% cardano_networks = Blockfrost.annotation(Blockfrost::CardanoNetworks)
         .args.first.map(&.id) %}

    Habitat.create do
      setting cardano_api_key : String?, validation: :validate_cardano_api_key
      setting ipfs_api_key : String?, validation: :validate_ipfs_api_key
      setting api_version : String = "v0", validation: :validate_api_version
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
        Habitat.raise_validation_error("API version is invalid")
    end
  {% end %}
end
