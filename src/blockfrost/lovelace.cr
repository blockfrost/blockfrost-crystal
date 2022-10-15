struct Blockfrost::Lovelace
  include JSON::Serializable

  getter unit : String
  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter quantity : Int64

  def to_ada
    quantity / 1_000_000
  end
end
