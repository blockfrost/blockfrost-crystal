struct Blockfrost::Asset
  include JSON::Serializable

  getter asset : String
  @[JSON::Field(converter: Blockfrost::Int128FromString)]
  getter quantity : Int128
  getter policy_id : String
  getter asset_name : String?
  getter fingerprint : String
  getter initial_mint_tx_hash : String
  getter mint_or_burn_count : Int32
  getter onchain_metadata : OnchainMetadata?
  getter metadata : Metadata?

  Blockfrost.gets_all_with_order_and_pagination(
    :all,
    Array(Abbreviated),
    "assets"
  )

  def self.get(asset : String)
    Asset.from_json(Client.get("assets/#{asset}"))
  end

  {% for method, model in {
                            addresses:    "Address",
                            history:      "Event",
                            transactions: "Transaction",
                          } %}

    Blockfrost.gets_all_with_order_and_pagination(
      :{{method.id}},
      Array({{model.id}}),
      "assets/#{asset}/{{method.id}}",
      asset : String
    )
  {% end %}

  Blockfrost.gets_all_with_order_and_pagination(
    :all_of_policy,
    Array(Abbreviated),
    "assets/policy/#{policy_id}",
    policy_id : String
  )

  struct Abbreviated
    include JSON::Serializable

    getter asset : String
    @[JSON::Field(converter: Blockfrost::Int128FromString)]
    getter quantity : Int128
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
    @[JSON::Field(converter: Blockfrost::Int128FromString)]
    getter quantity : Int128
  end

  struct Event
    include JSON::Serializable

    Blockfrost.enum_castable_from_string(Action, {
      Minted,
      Burned,
    })

    getter tx_hash : String
    @[JSON::Field(converter: Blockfrost::Int128FromString)]
    getter amount : Int128
    getter action : Action
  end

  struct Transaction
    include JSON::Serializable

    getter tx_hash : String
    getter tx_index : Int32
    getter block_height : Int32
    @[JSON::Field(converter: Blockfrost::TimeFromInt)]
    getter block_time : Time
  end
end
