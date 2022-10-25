abstract struct Blockfrost::BaseTransaction < Blockfrost::BaseResource
  getter tx_hash : String
  getter tx_index : Int32
  getter block_height : Int32
  @[JSON::Field(converter: Blockfrost::Json::TimeFromInt)]
  getter block_time : Time
end