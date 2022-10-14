struct Blockfrost::Metric < Blockfrost::Resource
  @[JSON::Field(converter: Blockfrost::Json::TimeFromInt)]
  getter time : Time
  getter calls : Int32

  def self.all : Array(Metric)
    Array(Metric).from_json(client.get("/metrics"))
  end

  def self.endpoints : Array(Endpoint)
    Array(Endpoint).from_json(client.get("/metrics/endpoints"))
  end

  struct Endpoint
    include JSON::Serializable

    @[JSON::Field(converter: Blockfrost::Json::TimeFromInt)]
    getter time : Time
    getter calls : Int32
    getter endpoint : String
  end
end
