struct Blockfrost::Transaction::Utxo < Blockfrost::BaseResource
  getter hash : String
  getter inputs : Array(Input)
  getter outputs : Array(Output)

  def self.get(hash : String) : Utxo
    Utxo.from_json(client.get("txs/#{hash}/utxos"))
  end

  struct Input
    include JSON::Serializable

    getter address : String
    getter amount : Array(Token)
    getter tx_hash : String
    getter output_index : Int32
    getter data_hash : String?
    getter collateral : Bool
  end

  struct Output
    include JSON::Serializable

    getter address : String
    getter amount : Array(Token)
    getter output_index : Int32
    getter data_hash : String?
  end
end
