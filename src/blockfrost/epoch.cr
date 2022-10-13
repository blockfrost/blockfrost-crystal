struct Blockfrost::Epoch < Blockfrost::Resource
  getter epoch : Int32
  @[JSON::Field(converter: Blockfrost::Json::TimeFromInt)]
  getter start_time : Time
  @[JSON::Field(converter: Blockfrost::Json::TimeFromInt)]
  getter end_time : Time
  @[JSON::Field(converter: Blockfrost::Json::TimeFromInt)]
  getter first_block_time : Time
  @[JSON::Field(converter: Blockfrost::Json::TimeFromInt)]
  getter last_block_time : Time
  getter block_count : Int32
  getter tx_count : Int32
  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter output : Int64
  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter fees : Int64
  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter active_stake : Int64

  def self.get(number : Int32) : Epoch
    Epoch.from_json(client.get("epochs/#{number}"))
  end

  def self.latest : Epoch
    Epoch.from_json(client.get("epochs/latest"))
  end

  {% for key in %w[next previous] %}
    def self.{{key.id}}(
      number : Int32,
      count : QueryCount? = nil,
      page : QueryPage? = nil
    ) : Array(Epoch)
      Array(Epoch).from_json(
        client.get("epochs/#{number}/{{key.id}}", {
          "count" => count,
          "page" => page
        })
      )
    end

    def {{key.id}}(
      count : QueryCount? = nil,
      page : QueryPage? = nil
    ) : Array(Epoch)
      Epoch.{{key.id}}(epoch, count: count, page: page)
    end
  {% end %}
end
