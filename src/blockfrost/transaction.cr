struct Blockfrost::Transaction < Blockfrost::Resource
  getter hash : String
  getter block : String
  getter block_height : Int32
  @[JSON::Field(converter: Blockfrost::Json::TimeFromInt)]
  getter block_time : Time
  getter slot : Int32
  getter index : Int32
  getter output_amount : Array(Unit)
  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter fees : Int64
  @[JSON::Field(converter: Blockfrost::Json::Int64FromString)]
  getter deposit : Int64
  getter size : Int32
  @[JSON::Field(converter: Blockfrost::Json::Int32FromString)]
  getter invalid_before : Int32?
  @[JSON::Field(converter: Blockfrost::Json::Int32FromString)]
  getter invalid_hereafter : Int32?
  getter utxo_count : Int32
  getter withdrawal_count : Int32
  getter mir_cert_count : Int32
  getter delegation_count : Int32
  getter stake_cert_count : Int32
  getter pool_update_count : Int32
  getter pool_retire_count : Int32
  getter asset_mint_or_burn_count : Int32
  getter redeemer_count : Int32
  getter valid_contract : Bool

  def self.get(hash : String) : Transaction
    Transaction.from_json(client.get("txs/#{hash}"))
  end
end
