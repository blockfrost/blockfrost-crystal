struct Blockfrost::Address < Blockfrost::BaseAddress
  getter amount : Array(Token)

  def self.get(address : String) : Address
    Address.from_json(client.get("addresses/#{address}"))
  end

  def self.extended(address : String) : Address::Extended
    Address::Extended.from_json(client.get("addresses/#{address}/extended"))
  end

  def self.total(address : String) : Total
    Total.from_json(client.get("addresses/#{address}/total"))
  end

  gets_all_with_order_and_pagination(
    :utxos,
    Array(UTXO),
    "addresses/#{address}/utxos",
    address : String
  )

  gets_all_scoped_with_order_and_pagination(
    :utxos_of_asset,
    Array(UTXO),
    "addresses/#{address}/utxos/#{asset}",
    address : String,
    asset : String
  )

  struct Extended < BaseAddress
    getter amount : Array(Token::Extended)
  end

  struct Total
    include JSON::Serializable

    getter address : String
    getter received_sum : Array(Token)
    getter sent_sum : Array(Token)
    getter tx_count : Int32
  end

  struct UTXO < BaseUTXO
  end
end
