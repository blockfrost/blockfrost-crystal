struct Blockfrost::Network
  include JSON::Serializable

  getter supply : Supply
  getter stake : Stake

  def self.get
    Network.from_json(Client.get("network"))
  end

  struct Supply
    include JSON::Serializable

    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter max : Int64
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter total : Int64
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter circulating : Int64
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter locked : Int64
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter treasury : Int64
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter reserves : Int64
  end

  struct Stake
    include JSON::Serializable

    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter live : Int64
    @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
    getter active : Int64
  end
end
