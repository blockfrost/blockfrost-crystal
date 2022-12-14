struct Blockfrost::Metric
  include JSON::Serializable

  @[JSON::Field(converter: Blockfrost::TimeFromInt)]
  getter time : Time
  getter calls : Int32

  def self.all
    Array(Metric).from_json(Client.get("metrics"))
  end

  def self.endpoints
    Array(Endpoint).from_json(Client.get("metrics/endpoints"))
  end

  struct Endpoint
    include JSON::Serializable

    @[JSON::Field(converter: Blockfrost::TimeFromInt)]
    getter time : Time
    getter calls : Int32
    getter endpoint : String
  end
end
