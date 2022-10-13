module Blockfrost
  extend self

  {% begin %}
    {% networks = Blockfrost.annotation(Blockfrost::Networks)
         .args.first.map(&.id) %}

    Habitat.create do
      setting api_key : String, validation: :validate_api_key
      setting api_version : String = "v0", validation: :validate_api_version
    end

    def network : String
      Habitat.raise_if_missing_settings!

      settings.api_key.match(/^({{networks.join('|').id}})/).try(&.[1]).to_s
    end

    def host : String
      case network
      when "ipfs"
        "https://#{network}.blockfrost.io"
      when "milkmainnet", "milktestnet"
        "https://milkomeda-#{network[4..-1]}.blockfrost.io"
      else
        "https://cardano-#{network}.blockfrost.io"
      end
    end

    def validate_api_key(value : String)
        value.match(/^({{networks.join('|').id}})[A-Za-z0-9]{32}/) ||
          Habitat.raise_validation_error("API key is invalid")
    end

    def validate_api_version(value : String)
      value.match(/^v\d$/) ||
        Habitat.raise_validation_error("API version is invalid")
    end

    {% for method in networks %}
      def {{method.id}}? : Bool
        network == "{{method}}"
      end
    {% end %}
  {% end %}
end
