struct Blockfrost::Asset < Blockfrost::BaseResource
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

  gets_all_with_order_and_pagination(
    :all,
    Array(Abbreviated),
    "assets"
  )

  def self.get(asset : String) : Asset
    Asset.from_json(client.get("assets/#{asset}"))
  end

  {% for method, model in {
                            addresses:    "Address",
                            history:      "Event",
                            transactions: "Transaction",
                          } %}

    gets_all_with_order_and_pagination(
      :{{method.id}},
      Array({{model.id}}),
      "assets/#{asset}/{{method.id}}",
      asset : String
    )
  {% end %}

  gets_all_with_order_and_pagination(
    :all_of_policy,
    Array(Abbreviated),
    "assets/policy/#{policy_id}",
    policy_id : String
  )

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

  struct Address
    include JSON::Serializable

    getter address : String
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter quantity : Int64
  end

  struct Event
    include JSON::Serializable

    getter tx_hash : String
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter amount : Int64
    getter action : String
  end

  struct Transaction
    include JSON::Serializable

    getter tx_hash : String
    getter tx_index : Int32
    getter block_height : Int32
    @[JSON::Field(converter: Blockfrost::Json::TimeFromInt)]
    getter block_time : Time
  end
end
