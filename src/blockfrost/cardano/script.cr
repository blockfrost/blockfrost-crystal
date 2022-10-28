struct Blockfrost::Script
  include JSON::Serializable

  Blockfrost.enum_castable_from_string(Type, {
    Timelock,
    PlutusV1,
    PlutusV2,
  }, camelcase(lower: true))

  getter script_hash : String
  getter type : Type
  getter serialised_size : Int32?

  Blockfrost.gets_all_with_order_and_pagination(
    :all,
    Array(Abbreviated),
    "scripts"
  )

  def self.get(script_hash : String)
    Script.from_json(Client.get("scripts/#{script_hash}"))
  end

  def self.json(script_hash : String)
    TimelockJSON.from_json(Client.get("scripts/#{script_hash}/json")).value
  end

  def self.cbor(script_hash : String)
    PlutusCBOR.from_json(Client.get("scripts/#{script_hash}/cbor")).value
  end

  Blockfrost.gets_all_with_order_and_pagination(
    :redeemers,
    Array(Redeemer),
    "scripts/#{script_hash}/redeemers",
    script_hash : String
  )

  struct Abbreviated
    include JSON::Serializable

    getter script_hash : String
  end

  struct TimelockJSON
    include JSON::Serializable

    @[JSON::Field(key: "json")]
    getter value : JSON::Any
  end

  struct PlutusCBOR
    include JSON::Serializable

    @[JSON::Field(key: "cbor")]
    getter value : String
  end

  struct Redeemer
    include JSON::Serializable
    include Shared::Redeemer

    getter tx_hash : String
  end
end
