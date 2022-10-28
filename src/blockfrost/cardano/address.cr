struct Blockfrost::Address
  include JSON::Serializable
  include Shared::AddressFields

  Blockfrost.enum_castable_from_string(Type, {
    Byron,
    Shelley,
  })

  getter amount : Array(Token)
  getter type : Type

  def self.get(address : String)
    Address.from_json(Client.get("addresses/#{address}"))
  end

  def self.extended(address : String)
    Address::Extended.from_json(Client.get("addresses/#{address}/extended"))
  end

  def self.total(address : String)
    Total.from_json(Client.get("addresses/#{address}/total"))
  end

  Blockfrost.gets_all_with_order_and_pagination(
    :utxos,
    Array(UTXO),
    "addresses/#{address}/utxos",
    address : String
  )

  Blockfrost.gets_all_scoped_with_order_and_pagination(
    :utxos_of_asset,
    Array(UTXO),
    "addresses/#{address}/utxos/#{asset}",
    address : String,
    asset : String
  )

  Blockfrost.gets_all_with_order_and_pagination_and_from_to(
    :transactions,
    Array(Transaction),
    "addresses/#{address}/transactions",
    address : String
  )

  struct Extended
    include JSON::Serializable
    include Shared::AddressFields

    getter amount : Array(Token::Extended)
    getter type : Type
  end

  struct Total
    include JSON::Serializable

    getter address : String
    getter received_sum : Array(Token)
    getter sent_sum : Array(Token)
    getter tx_count : Int32
  end

  struct UTXO
    include JSON::Serializable
    include Shared::UTXOFields

    getter tx_hash : String
    getter block : String
  end

  struct Transaction
    include JSON::Serializable

    getter tx_hash : String
    getter tx_index : Int32
    getter block_height : Int32
    @[JSON::Field(converter: Blockfrost::TimeFromInt)]
    getter block_time : Time
  end
end
