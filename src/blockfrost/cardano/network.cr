struct Blockfrost::Network
  include JSON::Serializable

  getter supply : Supply
  getter stake : Stake

  def self.get
    Network.from_json(Client.get("network"))
  end

  struct Supply
    include JSON::Serializable

    @[JSON::Field(converter: Blockfrost::Int128FromString)]
    getter max : Int128
    @[JSON::Field(converter: Blockfrost::Int128FromString)]
    getter total : Int128
    @[JSON::Field(converter: Blockfrost::Int128FromString)]
    getter circulating : Int128
    @[JSON::Field(converter: Blockfrost::Int128FromString)]
    getter locked : Int128
    @[JSON::Field(converter: Blockfrost::Int128FromString)]
    getter treasury : Int128
    @[JSON::Field(converter: Blockfrost::Int128FromString)]
    getter reserves : Int128
  end

  struct Stake
    include JSON::Serializable

    @[JSON::Field(converter: Blockfrost::Int128FromString)]
    getter live : Int128
    @[JSON::Field(converter: Blockfrost::Int128FromString)]
    getter active : Int128
  end
end
