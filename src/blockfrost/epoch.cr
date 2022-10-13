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
    Epoch.from_json(client.get("epoch/#{number}"))
  end

  def self.latest : Epoch
    Epoch.from_json(client.get("epoch/latest"))
  end
end
