struct Blockfrost::Asset < Blockfrost::Resource
  getter asset : String
  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter quantity : Int64
  getter policy_id : String
  getter asset_name : String?
  getter fingerprint : String
  getter initial_mint_tx_hash : String
  getter mint_or_burn_count : Int32
  getter onchain_metadata : OnchainMetadata?
  getter metadata : Metadata?

  def self.all(
    order : QueryOrder? = nil,
    count : QueryCount? = nil,
    page : QueryPage? = nil
  ) : Array(Abbreviated)
    Array(Abbreviated).from_json(
      client.get("assets", {
        "order" => order.try(&.to_s),
        "count" => count,
        "page"  => page,
      })
    )
  end

  def self.all(
    order : String? = nil,
    **args
  ) : Array(Abbreviated)
    all(order_from_string(order), **args)
  end

  def self.get(asset : String) : Asset
    Asset.from_json(client.get("assets/#{asset}"))
  end

  struct Abbreviated
    include JSON::Serializable

    getter asset : String
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter quantity : Int64
  end

  struct OnchainMetadata
    include JSON::Serializable

    getter name : String
    getter image : String
  end

  struct Metadata
    include JSON::Serializable

    getter name : String
    getter description : String
    getter ticker : String
    getter url : String
    getter logo : String
    getter decimals : Int32
  end
end
