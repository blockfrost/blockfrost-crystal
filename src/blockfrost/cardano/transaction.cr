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
  @[JSON::Field(converter: Blockfrost::Int128FromString)]
  getter fees : Int128
  @[JSON::Field(converter: Blockfrost::Int128FromString)]
  getter deposit : Int128
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
    UTXO.from_json(Client.get("txs/#{hash}/utxos"))
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

  def self.pool_updates(hash : String)
    Array(PoolUpdate).from_json(Client.get("txs/#{hash}/pool_updates"))
  end

  def pool_updates
    self.class.pool_updates(hash)
  end

  def self.pool_retires(hash : String)
    Array(PoolRetire).from_json(Client.get("txs/#{hash}/pool_retires"))
  end

  def pool_retires
    self.class.pool_retires(hash)
  end

  def self.metadata(hash : String)
    Array(MetadataJSON).from_json(Client.get("txs/#{hash}/metadata"))
  end

  def metadata
    self.class.metadata(hash)
  end

  def self.metadata_in_cbor(hash : String)
    Array(MetadataCBOR).from_json(Client.get("txs/#{hash}/metadata/cbor"))
  end

  def metadata_in_cbor
    self.class.metadata_in_cbor(hash)
  end

  def self.redeemers(hash : String)
    Array(Redeemer).from_json(Client.get("txs/#{hash}/redeemers"))
  end

  def redeemers
    self.class.redeemers(hash)
  end

  def self.submit(data : BodyData)
    String.from_json(
      Client.post(
        "tx/submit",
        body: data,
        content_type: "application/cbor"
      )
    )
  end

  struct UTXO
    include JSON::Serializable

    getter hash : String
    getter inputs : Array(Input)
    getter outputs : Array(Output)

    struct Input
      include JSON::Serializable
      include Shared::UTXOFields

      getter address : String
      getter collateral : Bool
      getter reference : Bool
      getter tx_hash : String
    end

    struct Output
      include JSON::Serializable
      include Shared::UTXOFields

      getter address : String
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
    @[JSON::Field(converter: Blockfrost::Int128FromString)]
    getter amount : Int128
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
    @[JSON::Field(converter: Blockfrost::Int128FromString)]
    getter amount : Int128
  end

  struct PoolUpdate
    include JSON::Serializable

    getter cert_index : Int32
    getter pool_id : String
    getter vrf_key : String
    @[JSON::Field(converter: Blockfrost::Int128FromString)]
    getter pledge : Int128
    getter margin_cost : Float64
    @[JSON::Field(converter: Blockfrost::Int128FromString)]
    getter fixed_cost : Int128
    getter reward_account : String
    getter owners : Array(String)
    getter metadata : Metadata?
    getter relays : Array(Relay)
    getter active_epoch : Int32

    struct Metadata
      include JSON::Serializable
      include Shared::PoolMetadataFields
    end

    struct Relay
      include JSON::Serializable
      include Shared::PoolRelayFields
    end
  end

  struct PoolRetire
    include JSON::Serializable

    getter cert_index : Int32
    getter pool_id : String
    getter retiring_epoch : Int32
  end

  struct MetadataJSON
    include JSON::Serializable

    getter label : String
    getter json_metadata : JSON::Any
  end

  struct MetadataCBOR
    include JSON::Serializable

    getter label : String
    getter metadata : String?
  end

  struct Redeemer
    include JSON::Serializable
    include Shared::RedeemerFields

    getter script_hash : String
  end
end
