abstract struct Blockfrost::Base::UTXO
  include JSON::Serializable

  getter tx_hash : String
  getter output_index : Int32
  getter amount : Array(Token)
  getter block : String
  getter data_hash : String?
  getter inline_datum : String?
  getter reference_script_hash : String?
end
