module Blockfrost::Shared::UTXOFields
  getter amount : Array(Token)
  getter data_hash : String?
  getter inline_datum : String?
  getter output_index : Int32
  getter reference_script_hash : String?
end
