abstract struct Blockfrost::Unit
  include JSON::Serializable

  @[JSON::Field(key: "quantity", converter: Blockfrost::Json::Int64FromString)]
  getter value : Int64
  getter unit : String

  use_json_discriminator "unit", {
    lovelace: Lovelace,
  }
end
