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

  DEFAULT_API_COUNT_PER_PAGE = 100
  DEFAULT_API_ORDER          = Blockfrost::QueryOrder::ASC

  MAX_COUNT_PER_PAGE                 =        100
  MAX_NUMBER_OF_CONCURRENT_REQUESTS  =        200
  MAX_PAGINATION_PAGES               = 21_474_836
  MAX_RETRIES_IN_CONCURRENT_REQUESTS =         10

  Habitat.create do
    setting cardano_api_key : String?,
      validation: :validate_cardano_api_key
    setting cardano_api_version : String = "v0",
      validation: :validate_api_version
    setting ipfs_api_key : String?,
      validation: :validate_ipfs_api_key
    setting ipfs_api_version : String = "v0",
      validation: :validate_api_version
    setting default_order : QueryOrder? = nil
    setting default_count_per_page : Int32? = nil,
      validation: :validate_count_per_page
    setting retries_in_concurrent_requests : Int32 = 5,
      validation: :validate_retries_in_concurrent_requests
    setting sleep_between_retries_ms : Int32 = 500,
      validation: :validate_sleep_between_retries_ms
  end

  def host_for_path(
    path : String
  ) : String
    case path
    when /^ipfs/ then "https://ipfs.blockfrost.io"
    else              "https://cardano-#{cardano_network}.blockfrost.io"
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
    else              settings.cardano_api_version
    end
  end

  {% begin %}
    {% cardano_networks = Blockfrost.annotation(Blockfrost::CardanoNetworks)
         .args.first.map(&.id) %}

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
  {% end %}

  def validate_ipfs_api_key(value : String?)
    return unless api_key = value

    api_key.match(/^ipfs[A-Za-z0-9]{32}/) ||
      Habitat.raise_validation_error("IPFS API key is invalid")
  end

  def validate_api_version(value : String)
    value.match(/^v\d+$/) ||
      Habitat.raise_validation_error(
        "API version is invalid (e.g. v0)")
  end

  def validate_default_order(value : QueryOrder | String?)
    return unless order = value

    Blockfrost::QueryOrder.names.map(&.downcase).includes?(order.to_s) ||
      Habitat.raise_validation_error(
        "Default order is invalid (either asc or desc)")
  end

  def validate_count_per_page(value : Int32?)
    return unless count = value

    (1..MAX_COUNT_PER_PAGE).includes?(count) ||
      Habitat.raise_validation_error(
        "Default count per page is invalid (min 1 and max %s)" %
        MAX_COUNT_PER_PAGE)
  end

  def validate_retries_in_concurrent_requests(value : Int32)
    (0..MAX_RETRIES_IN_CONCURRENT_REQUESTS).includes?(value) ||
      Habitat.raise_validation_error(
        "Maximum retries in concurrent requests is invalid (min 0 and max %s)" %
        MAX_RETRIES_IN_CONCURRENT_REQUESTS)
  end

  def validate_sleep_between_retries_ms(value : Int32)
    value >= 0 ||
      Habitat.raise_validation_error(
        "Sleep between retries must be greater than or equal to 0")
  end
end
