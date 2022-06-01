struct Blockfrost::Unit
  include JSON::Serializable

  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter quantity : Int64
  getter unit : String
end
