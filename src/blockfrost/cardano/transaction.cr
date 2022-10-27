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

  def self.utxos(hash : String)
    Utxo.from_json(Client.get("txs/#{hash}/utxos"))
  end

  def utxos
    self.class.utxos(hash)
  end

  def self.stakes(hash : String)
    Array(Stake).from_json(Client.get("txs/#{hash}/stakes"))
  end

  def stakes
    self.class.stakes(hash)
  end

  def self.delegations(hash : String)
    Array(Delegation).from_json(Client.get("txs/#{hash}/delegations"))
  end

  def delegations
    self.class.delegations(hash)
  end

  def self.withdrawals(hash : String)
    Array(Withdrawal).from_json(Client.get("txs/#{hash}/withdrawals"))
  end

  def withdrawals
    self.class.withdrawals(hash)
  end

  def self.mirs(hash : String)
    Array(Mir).from_json(Client.get("txs/#{hash}/mirs"))
  end

  def mirs
    self.class.mirs(hash)
  end

  struct Utxo
    include JSON::Serializable

    getter hash : String
    getter inputs : Array(Input)
    getter outputs : Array(Output)

    struct Input
      include JSON::Serializable

      getter address : String
      getter amount : Array(Token)
      getter tx_hash : String
      getter output_index : Int32
      getter data_hash : String?
      getter inline_datum : String?
      getter reference_script_hash : String?
      getter collateral : Bool
      getter reference : Bool
    end

    struct Output
      include JSON::Serializable

      getter address : String
      getter amount : Array(Token)
      getter output_index : Int32
      getter data_hash : String?
      getter inline_datum : String?
      getter reference_script_hash : String?
    end
  end

  struct Stake
    include JSON::Serializable

    getter cert_index : Int32
    getter address : String
    getter registration : Bool
  end

  struct Delegation
    include JSON::Serializable

    getter index : Int32
    getter cert_index : Int32
    getter address : String
    getter pool_id : String
    getter active_epoch : Int32
  end

  struct Withdrawal
    include JSON::Serializable

    getter address : String
    @[JSON::Field(converter: Blockfrost::Int64FromString)]
    getter amount : Int64
  end

  struct Mir
    include JSON::Serializable

    Blockfrost.enum_castable_from_string(Pot, {
      Reserve,
      Treasury,
    })

    getter pot : Pot
    getter cert_index : Int32
    getter address : String
    @[JSON::Field(converter: Blockfrost::Int64FromString)]
    getter amount : Int64
  end
end
