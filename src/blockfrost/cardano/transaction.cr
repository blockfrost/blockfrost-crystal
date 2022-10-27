struct Blockfrost::Transaction
  include JSON::Serializable

  getter hash : String
  getter block : String
  getter block_height : Int32
  @[JSON::Field(converter: Blockfrost::TimeFromInt)]
  getter block_time : Time
  getter slot : Int32
  getter index : Int32
  getter output_amount : Array(Token)
  @[JSON::Field(converter: Blockfrost::Int64FromString)]
  getter fees : Int64
  @[JSON::Field(converter: Blockfrost::Int64FromString)]
  getter deposit : Int64
  getter size : Int32
  @[JSON::Field(converter: Blockfrost::Int32FromString)]
  getter invalid_before : Int32?
  @[JSON::Field(converter: Blockfrost::Int32FromString)]
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

  def self.get(hash : String)
    Transaction.from_json(Client.get("txs/#{hash}"))
  end
end
