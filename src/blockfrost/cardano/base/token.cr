abstract struct Blockfrost::BaseToken
  include JSON::Serializable

  getter unit : String
  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter quantity : Int64
end
